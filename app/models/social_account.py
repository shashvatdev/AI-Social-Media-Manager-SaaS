from sqlalchemy import Column, String, Text, DateTime, Boolean, ForeignKey, UniqueConstraint
from app.core.database import Base
import uuid
from datetime import datetime

class SocialAccount(Base):
    __tablename__ = "social_accounts"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    brand_id = Column(String, ForeignKey("brands.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Platform: LINKEDIN, TWITTER, INSTAGRAM, FACEBOOK
    platform = Column(String, nullable=False, index=True)
    
    # Handle & profile details (e.g. "@techbrand" or "TechBrand Company")
    account_handle = Column(String, nullable=False)
    account_name = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    platform_user_id = Column(String, nullable=True)  # Platform's internal member/page ID

    # Tokens (Strictly kept in backend)
    access_token = Column(Text, nullable=False)
    refresh_token = Column(Text, nullable=True)
    token_expires_at = Column(DateTime, nullable=True)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Bariki: Prevent duplicate binding of same handle for same brand
    __table_args__ = (
        UniqueConstraint("brand_id", "platform", "account_handle", name="uq_brand_platform_handle"),
    )
