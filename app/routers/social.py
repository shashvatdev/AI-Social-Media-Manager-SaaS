from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.brand import Brand
from app.models.social_account import SocialAccount
from app.schemas.social_account import SocialAccountConnect, SocialAccountResponse
from app.services.oauth_service import OAuthService
from typing import List

router = APIRouter(prefix="/api/social", tags=["Social Media Accounts & OAuth"])

# ----------------- 1. OAUTH AUTHORIZATION URLS -----------------

@router.get("/oauth/{platform}/authorize")
def oauth_authorize(platform: str, brand_id: str = Query(..., description="Brand ID connecting account")):
    """
    Redirects user to official login page of LinkedIn, Twitter/X, or Meta (Instagram/Facebook).
    """
    platform_clean = platform.upper().strip()

    if platform_clean == "LINKEDIN":
        url = OAuthService.get_linkedin_auth_url(brand_id)
    elif platform_clean == "TWITTER":
        url = OAuthService.get_twitter_auth_url(brand_id)
    elif platform_clean in ["META", "INSTAGRAM", "FACEBOOK"]:
        url = OAuthService.get_meta_auth_url(brand_id)
    else:
        raise HTTPException(status_code=400, detail=f"Unsupported platform: {platform}")

    return {"auth_url": url, "platform": platform_clean}


# ----------------- 2. OAUTH CALLBACKS (REDIRECT BACK) -----------------

@router.get("/oauth/{platform}/callback", response_model=SocialAccountResponse)
def oauth_callback(platform: str, code: str = Query(...), state: str = Query(..., description="Carries brand_id"), db: Session = Depends(get_db)):
    """
    Official OAuth Callback. Platform returns here with 'code' and 'state' (brand_id).
    Backend automatically exchanges token and saves the connected account.
    """
    brand_id = state
    brand = db.query(Brand).filter(Brand.id == brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found for this authorization")

    platform_clean = platform.upper().strip()

    if platform_clean == "LINKEDIN":
        data = OAuthService.exchange_linkedin_token(code)
    elif platform_clean == "TWITTER":
        data = OAuthService.exchange_twitter_token(code)
    elif platform_clean in ["META", "INSTAGRAM", "FACEBOOK"]:
        data = OAuthService.exchange_meta_token(code)
        platform_clean = "INSTAGRAM"
    else:
        raise HTTPException(status_code=400, detail=f"Unsupported platform: {platform}")

    # Upsert account in DB
    existing = db.query(SocialAccount).filter(
        SocialAccount.brand_id == brand_id,
        SocialAccount.platform == platform_clean,
        SocialAccount.account_handle == data["account_handle"]
    ).first()

    if existing:
        existing.access_token = data["access_token"]
        existing.refresh_token = data.get("refresh_token") or existing.refresh_token
        existing.account_name = data.get("account_name") or existing.account_name
        existing.avatar_url = data.get("avatar_url") or existing.avatar_url
        existing.is_active = True
        db.commit()
        db.refresh(existing)
        return existing

    new_account = SocialAccount(
        brand_id=brand_id,
        platform=platform_clean,
        account_handle=data["account_handle"],
        account_name=data.get("account_name", data["account_handle"]),
        avatar_url=data.get("avatar_url"),
        platform_user_id=data.get("platform_user_id"),
        access_token=data["access_token"],
        refresh_token=data.get("refresh_token"),
        is_active=True
    )
    db.add(new_account)
    db.commit()
    db.refresh(new_account)
    return new_account


# ----------------- 3. DIRECT CONNECT & LISTING -----------------

@router.post("/connect", response_model=SocialAccountResponse, status_code=status.HTTP_201_CREATED)
def connect_account(data: SocialAccountConnect, db: Session = Depends(get_db)):
    """
    Connect a social account directly with provided credentials.
    """
    brand = db.query(Brand).filter(Brand.id == data.brand_id).first()
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")

    platform_clean = data.platform.upper().strip()
    valid_platforms = ["LINKEDIN", "TWITTER", "INSTAGRAM", "FACEBOOK"]
    if platform_clean not in valid_platforms:
        raise HTTPException(status_code=400, detail=f"Invalid platform. Must be one of {valid_platforms}")

    existing = db.query(SocialAccount).filter(
        SocialAccount.brand_id == data.brand_id,
        SocialAccount.platform == platform_clean,
        SocialAccount.account_handle == data.account_handle
    ).first()

    if existing:
        existing.access_token = data.access_token
        existing.refresh_token = data.refresh_token or existing.refresh_token
        existing.token_expires_at = data.token_expires_at or existing.token_expires_at
        existing.account_name = data.account_name or existing.account_name
        existing.avatar_url = data.avatar_url or existing.avatar_url
        existing.is_active = True
        db.commit()
        db.refresh(existing)
        return existing

    new_account = SocialAccount(
        brand_id=data.brand_id,
        platform=platform_clean,
        account_handle=data.account_handle,
        account_name=data.account_name or data.account_handle,
        avatar_url=data.avatar_url,
        platform_user_id=data.platform_user_id,
        access_token=data.access_token,
        refresh_token=data.refresh_token,
        token_expires_at=data.token_expires_at,
        is_active=True
    )
    db.add(new_account)
    db.commit()
    db.refresh(new_account)
    return new_account

@router.get("/accounts", response_model=List[SocialAccountResponse])
def list_accounts(brand_id: str = Query(..., description="Brand ID to fetch connected accounts for"), db: Session = Depends(get_db)):
    """
    List all connected social media accounts for a brand. Tokens are strictly excluded.
    """
    return db.query(SocialAccount).filter(SocialAccount.brand_id == brand_id).all()

@router.delete("/accounts/{account_id}", status_code=status.HTTP_200_OK)
def disconnect_account(account_id: str, db: Session = Depends(get_db)):
    """
    Disconnect a social account.
    """
    account = db.query(SocialAccount).filter(SocialAccount.id == account_id).first()
    if not account:
        raise HTTPException(status_code=404, detail="Social account not found")

    db.delete(account)
    db.commit()
    return {"success": True, "message": f"Disconnected {account.platform} account @{account.account_handle}"}
