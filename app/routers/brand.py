from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_optional_user
from app.models.user import User
from app.models.brand import Brand
from app.models.knowledge import BrandKnowledge
from app.models.strategy import BrandStrategy
from app.schemas.brand import BrandCreate, BrandResponse
from app.schemas.knowledge import ScrapeRequest, ScrapeResponse, KnowledgeItemResponse
from app.schemas.strategy import StrategyUpdateRequest, StrategyResponse
from app.services.scraper import ScraperService
from app.services.doc_parser import DocumentParserService
from app.services.ai_engine import AIEngineService
from typing import List, Optional

router = APIRouter(prefix="/api/brands", tags=["Brands & Content Strategy"])

@router.post("", response_model=BrandResponse, status_code=status.HTTP_201_CREATED)
def create_brand(
    brand_data: BrandCreate,
    current_user: Optional[User] = Depends(get_optional_user),
    db: Session = Depends(get_db)
):
    """
    Step 1: Create a brand profile. Binds to logged-in user if authenticated.
    """
    new_brand = Brand(
        user_id=current_user.id if current_user else None,
        name=brand_data.name,
        website_url=brand_data.website_url,
        industry=brand_data.industry,
        tagline=brand_data.tagline,
        mission=brand_data.mission,
        target_audience=brand_data.target_audience,
        tone_of_voice=brand_data.tone_of_voice,
        content_pillars=brand_data.content_pillars or [],
        banned_words=brand_data.banned_words or [],
    )
    db.add(new_brand)
    db.commit()
    db.refresh(new_brand)
    return new_brand

@router.get("", response_model=List[BrandResponse])
def list_brands(
    current_user: Optional[User] = Depends(get_optional_user),
    db: Session = Depends(get_db)
):
    """
    List all brands. If user is authenticated, returns user's brands.
    """
    query = db.query(Brand)
    if current_user:
        query = query.filter(Brand.user_id == current_user.id)
    return query.order_by(Brand.created_at.desc()).all()

@router.get("/{brand_id}", response_model=BrandResponse)
def get_brand(brand_id: str, db: Session = Depends(get_db)):
    """
    Fetch brand details by ID.
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")
    return brand

@router.post("/{brand_id}/scrape-url", response_model=ScrapeResponse)
def scrape_brand_website(brand_id: str, req: ScrapeRequest = None, db: Session = Depends(get_db)):
    """
    Step 2: Scrape brand website and ingest its voice, mission, products, and headings into knowledge base.
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    target_url = (req.url if req and req.url else brand.website_url)
    if not target_url:
        raise HTTPException(status_code=400, detail="No website URL provided in request or brand profile.")

    try:
        scraped = ScraperService.scrape_url(target_url)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Failed to scrape website: {str(e)}")

    summary_text = f"Title: {scraped['title']} | Description: {scraped['description']}"
    
    knowledge_entry = BrandKnowledge(
        brand_id=brand.id,
        source_type="WEBSITE_SCRAPE",
        title=target_url,
        content=scraped["extracted_text"],
        summary=summary_text
    )
    db.add(knowledge_entry)

    # Auto-update brand tagline if missing
    if not brand.tagline and scraped["description"]:
        brand.tagline = scraped["description"][:200]

    db.commit()
    db.refresh(knowledge_entry)

    return ScrapeResponse(
        success=True,
        message="Website scraped and saved to brand knowledge.",
        data=KnowledgeItemResponse(
            id=knowledge_entry.id,
            brand_id=knowledge_entry.brand_id,
            source_type=knowledge_entry.source_type,
            title=knowledge_entry.title,
            content_preview=knowledge_entry.content[:300],
            summary=knowledge_entry.summary,
            created_at=knowledge_entry.created_at
        ),
        extracted_headings=scraped["headings"],
        social_links=scraped["social_links"]
    )

@router.post("/{brand_id}/upload-docs", response_model=KnowledgeItemResponse, status_code=status.HTTP_201_CREATED)
async def upload_brand_doc(brand_id: str, file: UploadFile = File(...), db: Session = Depends(get_db)):
    """
    Step 3: Upload brand document (PDF, TXT, Markdown) and extract its knowledge.
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    content_bytes = await file.read()
    if not content_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")

    extracted_text = DocumentParserService.extract_text(content_bytes, file.filename)
    if not extracted_text:
        raise HTTPException(status_code=400, detail="Could not extract readable text from this file.")

    summary = f"Uploaded document: {file.filename} ({len(extracted_text)} characters)"

    knowledge_entry = BrandKnowledge(
        brand_id=brand.id,
        source_type="DOCUMENT_UPLOAD",
        title=file.filename,
        content=extracted_text,
        summary=summary
    )
    db.add(knowledge_entry)
    db.commit()
    db.refresh(knowledge_entry)

    return KnowledgeItemResponse(
        id=knowledge_entry.id,
        brand_id=knowledge_entry.brand_id,
        source_type=knowledge_entry.source_type,
        title=knowledge_entry.title,
        content_preview=knowledge_entry.content[:300],
        summary=knowledge_entry.summary,
        created_at=knowledge_entry.created_at
    )

@router.get("/{brand_id}/knowledge", response_model=List[KnowledgeItemResponse])
def get_brand_knowledge(brand_id: str, db: Session = Depends(get_db)):
    """
    Fetch all ingested knowledge documents & scraped data for a brand.
    """
    items = db.query(BrandKnowledge).filter(BrandKnowledge.brand_id == brand_id).all()
    return [
        KnowledgeItemResponse(
            id=item.id,
            brand_id=item.brand_id,
            source_type=item.source_type,
            title=item.title,
            content_preview=item.content[:300],
            summary=item.summary,
            created_at=item.created_at
        )
        for item in items
    ]

# ----------------- 4. AI CONTENT LEAD STRATEGY BLUEPRINT -----------------

@router.post("/{brand_id}/strategy/generate", response_model=StrategyResponse)
def generate_strategy(brand_id: str, db: Session = Depends(get_db)):
    """
    AI Content Lead Engine: Synthesizes scraped website and uploaded docs to formulate
    a complete 30-day Brand Social Media Strategy Blueprint.
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    knowledge_items = db.query(BrandKnowledge).filter(BrandKnowledge.brand_id == brand_id).all()
    snippets = [k.summary or k.content[:400] for k in knowledge_items]

    blueprint = AIEngineService.generate_brand_strategy(
        brand_name=brand.name,
        website_url=brand.website_url,
        industry=brand.industry,
        initial_tone=brand.tone_of_voice,
        initial_audience=brand.target_audience,
        knowledge_snippets=snippets
    )

    # Upsert strategy record
    existing = db.query(BrandStrategy).filter(BrandStrategy.brand_id == brand_id).first()
    if existing:
        existing.positioning_statement = blueprint.get("positioning_statement", "")
        existing.target_personas = blueprint.get("target_personas", [])
        existing.tone_guidelines = blueprint.get("tone_guidelines", {})
        existing.content_pillars = blueprint.get("content_pillars", [])
        existing.funnel_mix = blueprint.get("funnel_mix", {})
        existing.platform_playbooks = blueprint.get("platform_playbooks", {})
        existing.weekly_cadence = blueprint.get("weekly_cadence", {})
        db.commit()
        db.refresh(existing)
        return existing

    new_strat = BrandStrategy(
        brand_id=brand_id,
        positioning_statement=blueprint.get("positioning_statement", ""),
        target_personas=blueprint.get("target_personas", []),
        tone_guidelines=blueprint.get("tone_guidelines", {}),
        content_pillars=blueprint.get("content_pillars", []),
        funnel_mix=blueprint.get("funnel_mix", {}),
        platform_playbooks=blueprint.get("platform_playbooks", {}),
        weekly_cadence=blueprint.get("weekly_cadence", {}),
        is_approved=False
    )
    db.add(new_strat)
    db.commit()
    db.refresh(new_strat)
    return new_strat

@router.get("/{brand_id}/strategy", response_model=StrategyResponse)
def get_strategy(brand_id: str, db: Session = Depends(get_db)):
    """
    Fetch the strategic blueprint for a brand.
    """
    strategy = db.query(BrandStrategy).filter(BrandStrategy.brand_id == brand_id).first()
    if not strategy:
        raise HTTPException(status_code=404, detail="No strategy generated yet. Call POST /{brand_id}/strategy/generate first.")
    return strategy

@router.put("/{brand_id}/strategy", response_model=StrategyResponse)
def update_strategy(brand_id: str, req: StrategyUpdateRequest, db: Session = Depends(get_db)):
    """
    Human Review & Approval: Allows the user to edit or approve the AI Content Lead's strategy.
    """
    strategy = db.query(BrandStrategy).filter(BrandStrategy.brand_id == brand_id).first()
    if not strategy:
        raise HTTPException(status_code=404, detail="Strategy not found")

    if req.positioning_statement is not None:
        strategy.positioning_statement = req.positioning_statement
    if req.target_personas is not None:
        strategy.target_personas = req.target_personas
    if req.tone_guidelines is not None:
        strategy.tone_guidelines = req.tone_guidelines
    if req.content_pillars is not None:
        strategy.content_pillars = req.content_pillars
    if req.funnel_mix is not None:
        strategy.funnel_mix = req.funnel_mix
    if req.platform_playbooks is not None:
        strategy.platform_playbooks = req.platform_playbooks
    if req.weekly_cadence is not None:
        strategy.weekly_cadence = req.weekly_cadence
    if req.is_approved is not None:
        strategy.is_approved = req.is_approved

    db.commit()
    db.refresh(strategy)
    return strategy
