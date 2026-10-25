from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.brand import Brand
from app.models.knowledge import BrandKnowledge
from app.schemas.brand import BrandCreate, BrandResponse
from app.schemas.knowledge import ScrapeRequest, ScrapeResponse, KnowledgeItemResponse
from app.services.scraper import ScraperService
from app.services.doc_parser import DocumentParserService
from typing import List

router = APIRouter(prefix="/api/brands", tags=["Brands"])

@router.post("", response_model=BrandResponse, status_code=status.HTTP_201_CREATED)
def create_brand(brand_data: BrandCreate, db: Session = Depends(get_db)):
    """
    Step 1: Create a brand profile.
    """
    new_brand = Brand(
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
