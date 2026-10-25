from sqlalchemy import Column, String, Text, DateTime, JSON, ForeignKey
from app.core.database import Base
import uuid
from datetime import datetime

class PostStatus:
    PENDING_APPROVAL = "PENDING_APPROVAL"
    APPROVED = "APPROVED"
    CHANGES_REQUESTED = "CHANGES_REQUESTED"
    REJECTED = "REJECTED"
    PUBLISHING = "PUBLISHING"
    PUBLISHED = "PUBLISHED"
    FAILED = "FAILED"

class Post(Base):
    __tablename__ = "posts"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    brand_id = Column(String, ForeignKey("brands.id", ondelete="CASCADE"), nullable=False, index=True)
    social_account_id = Column(String, ForeignKey("social_accounts.id", ondelete="SET NULL"), nullable=True)

    # Platform: LINKEDIN, TWITTER, INSTAGRAM, FACEBOOK
    platform = Column(String, nullable=False, index=True)
    
    # Generated copy & media
    content = Column(Text, nullable=False)
    hashtags = Column(JSON, default=list)       # ["#AI", "#SaaS"]
    media_urls = Column(JSON, default=list)     # Image/Video URLs if any
    suggested_media_prompt = Column(Text, nullable=True)  # DALL-E / Flux prompt

    # Status & Review Flow
    status = Column(String, default=PostStatus.PENDING_APPROVAL, nullable=False, index=True)
    ai_reasoning = Column(Text, nullable=True)   # Why AI chose this theme/angle
    user_feedback = Column(Text, nullable=True)  # User comments during revision
    rejection_reason = Column(Text, nullable=True)

    # Scheduling & Execution
    scheduled_for = Column(DateTime, nullable=True, index=True)
    published_at = Column(DateTime, nullable=True)
    platform_post_id = Column(String, nullable=True)  # External Tweet/Post ID
    error_message = Column(Text, nullable=True)       # Failure logs if API failed

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
