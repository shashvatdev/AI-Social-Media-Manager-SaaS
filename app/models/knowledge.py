from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base
import uuid
from datetime import datetime

class BrandKnowledge(Base):
    __tablename__ = "brand_knowledge"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    brand_id = Column(String, ForeignKey("brands.id", ondelete="CASCADE"), nullable=False, index=True)
    source_type = Column(String, nullable=False)  # "WEBSITE_SCRAPE" or "DOCUMENT_UPLOAD"
    title = Column(String, nullable=False)        # URL or filename
    content = Column(Text, nullable=False)        # Extracted clean text
    summary = Column(Text, nullable=True)         # Short extracted summary / meta
    created_at = Column(DateTime, default=datetime.utcnow)
