from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class StrategyUpdateRequest(BaseModel):
    positioning_statement: Optional[str] = None
    target_personas: Optional[List[Dict[str, Any]]] = None
    tone_guidelines: Optional[Dict[str, Any]] = None
    content_pillars: Optional[List[Dict[str, Any]]] = None
    funnel_mix: Optional[Dict[str, Any]] = None
    platform_playbooks: Optional[Dict[str, Any]] = None
    weekly_cadence: Optional[Dict[str, Any]] = None
    is_approved: Optional[bool] = None

class StrategyResponse(BaseModel):
    id: str
    brand_id: str
    positioning_statement: str
    target_personas: List[Dict[str, Any]] = []
    tone_guidelines: Dict[str, Any] = {}
    content_pillars: List[Dict[str, Any]] = []
    funnel_mix: Dict[str, Any] = {}
    platform_playbooks: Dict[str, Any] = {}
    weekly_cadence: Dict[str, Any] = {}
    is_approved: bool
    version: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
