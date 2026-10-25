from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.routers import brand

# Create tables if not exist
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Autonomous AI Social Media Manager API",
    description="Backend API for brand onboarding, AI content generation with HITL approval, and social posting.",
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

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "ai-social-manager-backend"}
