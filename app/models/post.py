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
    media_urls = Column(JSON, default=list)     # [url1, url2]
    suggested_media_prompt = Column(Text, nullable=True)  # Prompt used for creative generator

    # Strategic Metadata (AI Content Lead Layer)
    pillar = Column(String, nullable=True)
    funnel_stage = Column(String, nullable=True)  # AWARENESS, AUTHORITY, CONVERSION
    hook_angle = Column(String, nullable=True)
    quality_score = Column(String, nullable=True) # e.g. "9.2/10"
    critic_notes = Column(Text, nullable=True)    # Feedback from AI quality critic

    # Status & Review Flow
    status = Column(String, default=PostStatus.PENDING_APPROVAL, nullable=False, index=True)
    ai_reasoning = Column(Text, nullable=True)   # Strategic reasoning
    user_feedback = Column(Text, nullable=True)  # User comments during revision
    rejection_reason = Column(Text, nullable=True)

    # Scheduling & Execution
    scheduled_for = Column(DateTime, nullable=True, index=True)
    published_at = Column(DateTime, nullable=True)
    platform_post_id = Column(String, nullable=True)  # External Tweet/Post ID
    error_message = Column(Text, nullable=True)       # Failure logs if API failed

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
