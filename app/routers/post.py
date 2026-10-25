from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.brand import Brand
from app.models.knowledge import BrandKnowledge
from app.models.strategy import BrandStrategy
from app.models.social_account import SocialAccount
from app.models.post import Post, PostStatus
from app.schemas.post import (
    PostGenerateRequest,
    PostApproveRequest,
    PostRejectRequest,
    PostChangeRequest,
    PostEditRequest,
    PostResponse
)
from app.services.ai_engine import AIEngineService
from app.services.image_generator import ImageGeneratorService
from app.services.publisher import SocialPublisherService
from typing import List, Optional
from datetime import datetime

router = APIRouter(prefix="/api/posts", tags=["AI Posts & Approval Engine"])

# ----------------- 1. AI GENERATION (ALWAYS PENDING_APPROVAL) -----------------

@router.post("/generate", response_model=List[PostResponse], status_code=status.HTTP_201_CREATED)
def generate_posts(req: PostGenerateRequest, db: Session = Depends(get_db)):
    """
    Step 1: AI generates post drafts tailored for the brand & target platform.
    CRITICAL QUALITY RULE: All generated posts are created with status PENDING_APPROVAL.
    They will NEVER be published until explicitly approved by the user.
    """
    brand = db.query(Brand).filter(Brand.id == req.brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    platform_clean = req.platform.upper().strip()

    # Find connected social account if any
    social_acc = db.query(SocialAccount).filter(
        SocialAccount.brand_id == brand.id,
        SocialAccount.platform == platform_clean,
        SocialAccount.is_active == True
    ).first()

    # Fetch brand knowledge snippets
    knowledge_entries = db.query(BrandKnowledge).filter(BrandKnowledge.brand_id == brand.id).all()
    knowledge_snippets = [k.summary or k.content[:350] for k in knowledge_entries]

    # Fetch approved brand strategy if exists
    strategy_record = db.query(BrandStrategy).filter(BrandStrategy.brand_id == brand.id).first()
    strategy_dict = None
    if strategy_record:
        strategy_dict = {
            "positioning_statement": strategy_record.positioning_statement,
            "target_personas": strategy_record.target_personas,
            "tone_guidelines": strategy_record.tone_guidelines,
            "content_pillars": strategy_record.content_pillars,
            "funnel_mix": strategy_record.funnel_mix,
            "platform_playbooks": strategy_record.platform_playbooks
        }

    # Generate posts via AI Engine
    generated_items = AIEngineService.generate_posts(
        brand_name=brand.name,
        platform=platform_clean,
        strategy=strategy_dict,
        tone=brand.tone_of_voice,
        target_audience=brand.target_audience,
        content_pillars=brand.content_pillars or [],
        banned_words=brand.banned_words or [],
        knowledge_snippets=knowledge_snippets,
        topic=req.topic,
        count=req.count or 1
    )

    created_posts = []
    for item in generated_items:
        # Generate real visual creative URL if requested
        media_urls = []
        if req.generate_creatives and item.get("suggested_media_prompt"):
            image_url = ImageGeneratorService.generate_image_url(
                item["suggested_media_prompt"],
                brand.name
            )
            media_urls.append(image_url)

        post = Post(
            brand_id=brand.id,
            social_account_id=social_acc.id if social_acc else None,
            platform=platform_clean,
            content=item["content"],
            hashtags=item.get("hashtags", []),
            media_urls=media_urls,
            suggested_media_prompt=item.get("suggested_media_prompt"),
            
            # Content Lead & Strategy Layer
            pillar=item.get("pillar"),
            funnel_stage=item.get("funnel_stage"),
            hook_angle=item.get("hook_angle"),
            quality_score=item.get("quality_score"),
            critic_notes=item.get("critic_notes"),
            
            status=PostStatus.PENDING_APPROVAL,  # Must be approved by human
            ai_reasoning=item.get("ai_reasoning")
        )
        db.add(post)
        created_posts.append(post)

    db.commit()
    for p in created_posts:
        db.refresh(p)

    return created_posts


# ----------------- 2. REVIEW & APPROVAL WORKFLOW (HITL) -----------------

@router.post("/{post_id}/approve", response_model=PostResponse)
def approve_post(post_id: str, req: PostApproveRequest = None, db: Session = Depends(get_db)):
    """
    User Action: APPROVE.
    Transitions post status from PENDING_APPROVAL to APPROVED.
    Post is now eligible for scheduled publishing.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    if post.status in [PostStatus.PUBLISHED, PostStatus.PUBLISHING]:
        raise HTTPException(status_code=400, detail=f"Cannot approve post that is already {post.status}")

    post.status = PostStatus.APPROVED
    if req and req.scheduled_for:
        post.scheduled_for = req.scheduled_for
        if req.scheduled_for > datetime.utcnow():
            post.status = PostStatus.SCHEDULED
    else:
        post.scheduled_for = datetime.utcnow()

    post.rejection_reason = None
    db.commit()
    db.refresh(post)
    return post


@router.post("/{post_id}/reject", response_model=PostResponse)
def reject_post(post_id: str, req: PostRejectRequest = None, db: Session = Depends(get_db)):
    """
    User Action: REJECT.
    Transitions post to REJECTED. Will NOT be published.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    post.status = PostStatus.REJECTED
    post.rejection_reason = req.reason if req else "Rejected by user"
    db.commit()
    db.refresh(post)
    return post


@router.post("/{post_id}/request-changes", response_model=PostResponse)
def request_changes_and_refine(post_id: str, req: PostChangeRequest, db: Session = Depends(get_db)):
    """
    User Action: ASK AI TO REWRITE.
    User provides feedback (e.g. "make it shorter"), AI rewrites the copy.
    Status remains in review until approved.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    brand = db.query(Brand).filter(Brand.id == post.brand_id).first()

    refined_text = AIEngineService.refine_post(
        original_content=post.content,
        user_feedback=req.feedback,
        brand_name=brand.name if brand else "Brand",
        platform=post.platform
    )

    post.content = refined_text
    post.user_feedback = req.feedback
    post.status = PostStatus.PENDING_APPROVAL  # Remains pending user approval
    db.commit()
    db.refresh(post)
    return post


@router.put("/{post_id}/edit", response_model=PostResponse)
def edit_post_content(post_id: str, req: PostEditRequest, db: Session = Depends(get_db)):
    """
    User Action: MANUAL EDIT.
    User directly edits the caption or hashtags.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    post.content = req.content
    if req.hashtags is not None:
        post.hashtags = req.hashtags
    if req.media_urls is not None:
        post.media_urls = req.media_urls

    db.commit()
    db.refresh(post)
    return post


# ----------------- 3. PUBLISHING DISPATCHER ENDPOINT -----------------

@router.post("/{post_id}/publish-now", response_model=PostResponse)
def publish_post_now(post_id: str, db: Session = Depends(get_db)):
    """
    Publishes an approved post to its designated social media handle immediately.
    Security Rule: If post is not approved yet, it will fail unless explicitly confirmed.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    if post.status == PostStatus.PUBLISHED:
        raise HTTPException(status_code=400, detail="This post is already published.")

    # Find the connected social media account for this brand and platform
    account = None
    if post.social_account_id:
        account = db.query(SocialAccount).filter(SocialAccount.id == post.social_account_id).first()
    else:
        account = db.query(SocialAccount).filter(
            SocialAccount.brand_id == post.brand_id,
            SocialAccount.platform == post.platform,
            SocialAccount.is_active == True
        ).first()

    if not account:
        raise HTTPException(
            status_code=400,
            detail=f"No active connected {post.platform} account found for this brand. Please connect an account first in /api/social/connect"
        )

    # Transition to PUBLISHING to lock against race conditions
    post.status = PostStatus.PUBLISHING
    db.commit()

    try:
        dispatch_result = SocialPublisherService.publish(post, account)
        post.status = PostStatus.PUBLISHED
        post.published_at = datetime.utcnow()
        post.platform_post_id = dispatch_result.get("platform_post_id")
        post.error_message = None
        db.commit()
        db.refresh(post)
        return post
    except Exception as e:
        post.status = PostStatus.FAILED
        post.error_message = str(e)
        db.commit()
        db.refresh(post)
        raise HTTPException(status_code=500, detail=f"Failed to publish post: {str(e)}")


# ----------------- 4. LISTING & FEED ENDPOINTS -----------------

@router.get("", response_model=List[PostResponse])
def list_posts(
    brand_id: str = Query(..., description="Brand ID to filter posts"),
    status: Optional[str] = Query(None, description="Filter by status (PENDING_APPROVAL, APPROVED, etc.)"),
    platform: Optional[str] = Query(None, description="Filter by platform (LINKEDIN, TWITTER)"),
    db: Session = Depends(get_db)
):
    """
    Fetch posts feed for a brand, easily filterable for the 'Review Inbox' or 'Scheduled Queue'.
    """
    query = db.query(Post).filter(Post.brand_id == brand_id)
    if status:
        query = query.filter(Post.status == status.upper().strip())
    if platform:
        query = query.filter(Post.platform == platform.upper().strip())

    return query.order_by(Post.created_at.desc()).all()


@router.get("/{post_id}", response_model=PostResponse)
def get_single_post(post_id: str, db: Session = Depends(get_db)):
    """
    Get full details of a specific post.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    return post
