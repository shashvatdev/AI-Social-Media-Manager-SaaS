from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class ScrapeRequest(BaseModel):
    url: Optional[str] = None  # If omitted, uses brand.website_url

class KnowledgeItemResponse(BaseModel):
    id: str
    brand_id: str
    source_type: str
    title: str
    content_preview: str
    summary: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

class ScrapeResponse(BaseModel):
    success: bool
    message: str
    data: KnowledgeItemResponse
    extracted_headings: List[str] = []
    social_links: List[str] = []
