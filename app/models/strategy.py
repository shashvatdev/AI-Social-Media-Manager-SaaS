from sqlalchemy import Column, String, Text, DateTime, JSON, Boolean, ForeignKey
from app.core.database import Base
import uuid
from datetime import datetime

class BrandStrategy(Base):
    __tablename__ = "brand_strategies"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    brand_id = Column(String, ForeignKey("brands.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)

    # Core Strategy Blueprint
    positioning_statement = Column(Text, nullable=False)
    target_personas = Column(JSON, default=list)  # [{name, title, pain_points, desires, objections}]
    tone_guidelines = Column(JSON, default=dict)   # {tone_spectrum, voice_traits, banned_cliches, style_rules}
    content_pillars = Column(JSON, default=list)   # [{name, target_percentage, focus_theme, example_angles}]
    funnel_mix = Column(JSON, default=dict)        # {awareness: 40, authority: 35, conversion: 25}
    platform_playbooks = Column(JSON, default=dict) # {linkedin: {...}, instagram: {...}}
    weekly_cadence = Column(JSON, default=dict)    # {recommended_frequency, best_times}

    is_approved = Column(Boolean, default=False)   # User reviews & approves this strategic plan
    version = Column(String, default="1.0")

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
