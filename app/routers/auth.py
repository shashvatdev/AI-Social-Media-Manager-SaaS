from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import hash_password, verify_password, create_access_token
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.auth import UserSignupRequest, UserLoginRequest, TokenResponse, UserResponse

router = APIRouter(prefix="/api/auth", tags=["Authentication & User Management"])

@router.post("/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def signup(req: UserSignupRequest, db: Session = Depends(get_db)):
    """
    Registers a new SaaS user account, hashes password, and returns JWT session token.
    """
    email_clean = req.email.lower().strip()

    # Check if email is already registered
    existing_user = db.query(User).filter(User.email == email_clean).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email address already exists. Please log in."
        )

    # Hash password securely
    hashed_pwd = hash_password(req.password)

    # Create new user
    new_user = User(
        email=email_clean,
        full_name=req.full_name.strip(),
        hashed_password=hashed_pwd,
        company_name=req.company_name,
        role="OWNER",
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Generate JWT token
    token = create_access_token(data={"sub": new_user.id, "email": new_user.email})

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=new_user
    )

@router.post("/login", response_model=TokenResponse)
def login(req: UserLoginRequest, db: Session = Depends(get_db)):
    """
    Authenticates user credentials and returns a fresh JWT session token.
    """
    email_clean = req.email.lower().strip()
    user = db.query(User).filter(User.email == email_clean).first()

    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password. Please check your credentials.",
            headers={"WWW-Authenticate": "Bearer"}
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This account has been deactivated. Please contact support."
        )

    token = create_access_token(data={"sub": user.id, "email": user.email})

    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=user
    )

@router.get("/me", response_model=UserResponse)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """
    Fetches the authenticated user's profile and active session details.
    """
    return current_user
