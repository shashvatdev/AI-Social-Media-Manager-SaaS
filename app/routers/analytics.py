from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.post import Post, PostStatus
from app.models.brand import Brand
from pydantic import BaseModel
from typing import Dict, Any, List

router = APIRouter(prefix="/api/brands/{brand_id}/analytics", tags=["Brand Analytics"])

class AnalyticsResponse(BaseModel):
    brand_id: str
    total_posts: int
    published_count: int
    scheduled_count: int
    pending_approval_count: int
    rejected_count: int
    approval_rate: float
    avg_quality_score: float
    pillar_distribution: Dict[str, int]
    platform_distribution: Dict[str, int]
    funnel_distribution: Dict[str, int]

@router.get("", response_model=AnalyticsResponse)
def get_brand_analytics(brand_id: str, db: Session = Depends(get_db)):
    """
    Computes real-time editorial KPIs & performance metrics for a brand.
    Calculates approval rate, quality critic score, and strategic distribution.
    """
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    posts = db.query(Post).filter(Post.brand_id == brand_id).all()
    total_posts = len(posts)

    if total_posts == 0:
        return AnalyticsResponse(
            brand_id=brand_id,
            total_posts=0,
            published_count=0,
            scheduled_count=0,
            pending_approval_count=0,
            rejected_count=0,
            approval_rate=100.0,
            avg_quality_score=9.5,
            pillar_distribution={},
            platform_distribution={},
            funnel_distribution={}
        )

    published = sum(1 for p in posts if p.status == PostStatus.PUBLISHED)
    scheduled = sum(1 for p in posts if p.status in [PostStatus.SCHEDULED, PostStatus.APPROVED])
    pending = sum(1 for p in posts if p.status == PostStatus.PENDING_APPROVAL)
    rejected = sum(1 for p in posts if p.status == PostStatus.REJECTED)

    reviewed_total = published + scheduled + rejected
    approval_rate = round(((published + scheduled) / reviewed_total * 100), 1) if reviewed_total > 0 else 100.0

    # Extract quality scores
    scores = []
    for p in posts:
        if p.quality_score:
            try:
                # e.g. "9.4/10" -> 9.4
                val = float(p.quality_score.split("/")[0].strip())
                scores.append(val)
            except Exception:
                pass
    avg_quality = round(sum(scores) / len(scores), 1) if scores else 9.5

    # Distributions
    pillar_dist: Dict[str, int] = {}
    platform_dist: Dict[str, int] = {}
    funnel_dist: Dict[str, int] = {}

    for p in posts:
        # Pillar
        pil = p.pillar or "General Authority"
        pillar_dist[pil] = pillar_dist.get(pil, 0) + 1

        # Platform
        plat = p.platform.capitalize()
        platform_dist[plat] = platform_dist.get(plat, 0) + 1

        # Funnel
        fnl = p.funnel_stage or "Awareness"
        funnel_dist[fnl] = funnel_dist.get(fnl, 0) + 1

    return AnalyticsResponse(
        brand_id=brand_id,
        total_posts=total_posts,
        published_count=published,
        scheduled_count=scheduled,
        pending_approval_count=pending,
        rejected_count=rejected,
        approval_rate=approval_rate,
        avg_quality_score=avg_quality,
        pillar_distribution=pillar_dist,
        platform_distribution=platform_dist,
        funnel_distribution=funnel_dist
    )
