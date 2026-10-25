from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class SocialAccountConnect(BaseModel):
    brand_id: str
    platform: str  # LINKEDIN, TWITTER, INSTAGRAM, FACEBOOK
    account_handle: str
    account_name: Optional[str] = None
    avatar_url: Optional[str] = None
    platform_user_id: Optional[str] = None
    access_token: str
    refresh_token: Optional[str] = None
    token_expires_at: Optional[datetime] = None

class SocialAccountResponse(BaseModel):
    id: str
    brand_id: str
    platform: str
    account_handle: str
    account_name: Optional[str] = None
    avatar_url: Optional[str] = None
    is_active: bool
    created_at: datetime
    # Notice: access_token and refresh_token are NEVER returned in response for security!

    class Config:
        from_attributes = True
