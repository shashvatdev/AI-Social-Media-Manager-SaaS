from pydantic import BaseModel, HttpUrl
from typing import Optional, List
from datetime import datetime

class BrandCreate(BaseModel):
    name: str
    website_url: Optional[str] = None
    industry: Optional[str] = None
    tagline: Optional[str] = None
    mission: Optional[str] = None
    target_audience: Optional[str] = None
    tone_of_voice: Optional[str] = None
    content_pillars: Optional[List[str]] = []
    banned_words: Optional[List[str]] = []

class BrandResponse(BaseModel):
    id: str
    user_id: Optional[str] = None
    name: str
    website_url: Optional[str] = None
    industry: Optional[str] = None
    tagline: Optional[str] = None
    mission: Optional[str] = None
    target_audience: Optional[str] = None
    tone_of_voice: Optional[str] = None
    content_pillars: List[str] = []
    banned_words: List[str] = []
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
