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
from pydantic import BaseModel
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

class BrainQueryRequest(BaseModel):
    question: str

class BrainQueryResponse(BaseModel):
    brand_id: str
    question: str
    answer: str
    cited_sources: List[str]

@router.post("/{brand_id}/brain/query", response_model=BrainQueryResponse)
def query_brand_brain(brand_id: str, req: BrainQueryRequest, db: Session = Depends(get_db)):
    """
    RAG Grounding Endpoint: Queries the Brand Brain memory and uses Groq LLM
    to synthesize a strictly fact-based response citing ingested documents & scraped web pages.
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    items = db.query(BrandKnowledge).filter(BrandKnowledge.brand_id == brand_id).all()
    knowledge_list = [{"title": k.title, "content": k.content} for k in items]

    result = AIEngineService.query_knowledge_base(
        brand_name=brand.name,
        question=req.question.strip(),
        knowledge_items=knowledge_list
    )

    return BrainQueryResponse(
        brand_id=brand.id,
        question=req.question,
        answer=result.get("answer", "No response could be generated."),
        cited_sources=result.get("cited_sources", [])
    )

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

@router.get("/{brand_id}/export")
def export_brand_executive_report(brand_id: str, db: Session = Depends(get_db)):
    """
    Generates a presentation-ready executive Markdown report containing:
    - Executive Brand DNA & Positioning
    - ICP Target Personas
    - 30-Day Strategy Blueprint
    - Scheduled & Approved Content Pipeline with Creative Asset URLs
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    strategy = db.query(BrandStrategy).filter(BrandStrategy.brand_id == brand_id).first()
    from app.models.post import Post
    posts = db.query(Post).filter(Post.brand_id == brand_id).order_by(Post.created_at.desc()).all()

    from datetime import datetime
    now_str = datetime.utcnow().strftime("%B %d, %Y")

    md = [
        f"# 30-Day Editorial Content Blueprint & Publishing Schedule",
        f"**Brand**: {brand.name}",
        f"**Date**: {now_str}",
        f"**Tone Spectrum**: {brand.tone_of_voice or 'Authoritative, direct'}",
        f"**Target ICP**: {brand.target_audience or 'Founders, Executives'}",
        "\n---\n",
        "## 1. Brand Strategic Positioning",
    ]

    if strategy and strategy.positioning_statement:
        md.append(f"> {strategy.positioning_statement}\n")
    else:
        md.append(f"> {brand.tagline or 'Autonomous Content Lead strategy pending.'}\n")

    if strategy and strategy.target_personas:
        md.append("## 2. Target ICP Personas")
        for persona in strategy.target_personas:
            if isinstance(persona, dict):
                md.append(f"- **{persona.get('name', 'Persona')}**: {persona.get('role', '')} — *{persona.get('pain_points', '')}*")
            else:
                md.append(f"- {persona}")
        md.append("\n")

    if strategy and strategy.content_pillars:
        md.append("## 3. Content Pillars & Funnel Allocation")
        for pillar in strategy.content_pillars:
            if isinstance(pillar, dict):
                md.append(f"- **{pillar.get('name', 'Pillar')}** ({pillar.get('percentage', '30%')}): {pillar.get('description', '')}")
            else:
                md.append(f"- {pillar}")
        md.append("\n")

    md.append("## 4. Editorial Content Pipeline")
    if not posts:
        md.append("*No posts generated yet. Generate posts in the Approval Inbox to populate this schedule.*")
    else:
        for idx, post in enumerate(posts, 1):
            sched_str = post.scheduled_for.strftime("%b %d, %Y - %I:%M %p") if post.scheduled_for else "Unscheduled"
            media_str = f"![Creative]({post.media_urls[0]})\n" if post.media_urls else ""
            md.append(f"### #{idx} [{post.platform.upper()}] - {post.status}")
            md.append(f"- **Pillar**: {post.pillar or 'General'} | **Funnel**: {post.funnel_stage or 'Awareness'} | **Quality**: {post.quality_score or '9.5/10'}")
            md.append(f"- **Schedule**: {sched_str}")
            md.append(f"\n{post.content}\n")
            if post.hashtags:
                md.append(f"*{' '.join(post.hashtags)}*\n")
            if media_str:
                md.append(media_str)
            md.append("---\n")

    report_markdown = "\n".join(md)
    return {
        "brand_id": brand.id,
        "brand_name": brand.name,
        "total_posts": len(posts),
        "report_markdown": report_markdown
    }
