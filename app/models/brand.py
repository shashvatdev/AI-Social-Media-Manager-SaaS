from sqlalchemy import Column, String, Text, DateTime, JSON
from app.core.database import Base
import uuid
from datetime import datetime

class Brand(Base):
    __tablename__ = "brands"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False, index=True)
    website_url = Column(String, nullable=True)
    industry = Column(String, nullable=True)
    tagline = Column(String, nullable=True)
    mission = Column(Text, nullable=True)
    target_audience = Column(Text, nullable=True)
    tone_of_voice = Column(String, nullable=True)
    content_pillars = Column(JSON, default=list)  # list of strings
    banned_words = Column(JSON, default=list)     # list of strings
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
