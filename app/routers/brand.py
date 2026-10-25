from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.brand import Brand
from app.schemas.brand import BrandCreate, BrandResponse
from typing import List

router = APIRouter(prefix="/api/brands", tags=["Brands"])

@router.post("", response_model=BrandResponse, status_code=status.HTTP_201_CREATED)
def create_brand(brand_data: BrandCreate, db: Session = Depends(get_db)):
    """
    Step 1 API: Create a new brand profile with core details, tone, audience, and pillars.
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
