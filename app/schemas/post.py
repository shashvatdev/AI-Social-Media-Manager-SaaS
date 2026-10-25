from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class PostGenerateRequest(BaseModel):
    brand_id: str
    platform: str  # LINKEDIN, TWITTER, INSTAGRAM, FACEBOOK
    topic: Optional[str] = None
    count: Optional[int] = 3

class PostApproveRequest(BaseModel):
    scheduled_for: Optional[datetime] = None  # If omitted, ready for immediate dispatch

class PostRejectRequest(BaseModel):
    reason: Optional[str] = "Not aligned with current goals"

class PostChangeRequest(BaseModel):
    feedback: str  # e.g., "Make it shorter and more witty"

class PostEditRequest(BaseModel):
    content: str
    hashtags: Optional[List[str]] = None

class PostResponse(BaseModel):
    id: str
    brand_id: str
    social_account_id: Optional[str] = None
    platform: str
    content: str
    hashtags: List[str] = []
    media_urls: List[str] = []
    suggested_media_prompt: Optional[str] = None
    status: str
    ai_reasoning: Optional[str] = None
    user_feedback: Optional[str] = None
    rejection_reason: Optional[str] = None
    scheduled_for: Optional[datetime] = None
    published_at: Optional[datetime] = None
    platform_post_id: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
