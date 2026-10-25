from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from app.core.database import engine, Base
from app.models.user import User
from app.models.brand import Brand
from app.models.knowledge import BrandKnowledge
from app.models.social_account import SocialAccount
from app.models.post import Post
from app.models.strategy import BrandStrategy
from app.routers import auth, brand, social, post, analytics
from app.services.scheduler import AutonomousSchedulerDaemon
import os

# Create tables if not exist
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Launch autonomous scheduled post dispatcher
    await AutonomousSchedulerDaemon.start(check_interval_seconds=30)
    yield
    # Shutdown: Cleanly halt scheduler daemon
    await AutonomousSchedulerDaemon.stop()

app = FastAPI(
    title="Autonomous AI Social Media Manager API",
    description="Enterprise-grade AI Social Media Content Lead SaaS Backend. Ingests brand intelligence, formulates content strategies, generates platform-native posts with Flux visuals, and enforces strict human-in-the-loop review.",
    version="2.1.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure uploads directory exists
uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(os.path.join(uploads_dir, "creatives"), exist_ok=True)
app.mount("/static", StaticFiles(directory=uploads_dir), name="static")

# Include Routers
app.include_router(auth.router)
app.include_router(brand.router)
app.include_router(social.router)
app.include_router(post.router)
app.include_router(analytics.router)

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "ai-social-manager-backend",
        "auth_engine": "JWT + Bcrypt (Multi-Tenant)",
        "llm_provider": "Groq",
        "image_engine": "Flux",
        "approval_system": "Human-In-The-Loop (Enforced)"
    }
