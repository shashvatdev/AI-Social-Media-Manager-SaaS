from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.models.brand import Brand
from app.models.knowledge import BrandKnowledge
from app.models.social_account import SocialAccount
from app.models.post import Post
from app.routers import brand, social, post

# Create tables if not exist
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Autonomous AI Social Media Manager API",
    description="Backend API for brand onboarding, knowledge ingestion, social account linking, and AI publishing with Human-In-The-Loop approval.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(brand.router)
app.include_router(social.router)
app.include_router(post.router)

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "ai-social-manager-backend"}
