# Autonomous AI Social Media Manager SaaS

> **Autonomous AI Content Lead & Creative Director** for Modern B2B & D2C Founders.  
> Powered by **FastAPI**, **Groq LLM (`qwen/qwen3.8-27b`)**, **Flux Ultra-HD Creatives**, and an ultra-luxury editorial **Flutter Client**.

---

## 💎 Design Philosophy & Color System

The user interface follows an **editorial luxury SaaS** aesthetic inspired by haute-couture publication design:

| Palette Role | Color Hex | Visual Purpose |
| :--- | :--- | :--- |
| **Deep Aubergine** | `#3A0F34` | Primary brand accent & rich card backgrounds |
| **Dark Canvas** | `#190618` | Scaffold dark obsidian background |
| **Marigold** | `#EAAA00` | High-conversion primary CTAs, glows, and badges |
| **Ice Silver** | `#DDE3E8` | High-contrast headings and crisp editorial typography |
| **Surface Dark** | `#260B22` | Form fields, containers, and elevated surfaces |

### Typography
- **Headings & Display**: *Playfair Display* / *Cormorant Garamond* (Editorial, bespoke authority)
- **UI & Controls**: *Plus Jakarta Sans* (Legible, crisp engineering precision)

---

## 🏛 Architecture Overview

```
├── app/                          # FastAPI Multi-Tenant Backend
│   ├── core/                     # Database, Security (JWT/bcrypt), Config
│   ├── models/                   # SQLAlchemy ORM Models
│   │   ├── user.py               # Multi-tenant founder accounts
│   │   ├── brand.py              # Brand DNA, tone, pillars, guidelines
│   │   ├── knowledge.py          # Scraped web pages & parsed PDF/MD knowledge assets
│   │   ├── strategy.py           # 30-Day strategy blueprints (positioning, personas, pillars)
│   │   ├── post.py               # Generated social copy, Flux visuals, critic score, HITL status
│   │   └── social_account.py     # OAuth credentials (LinkedIn, Twitter, IG)
│   ├── services/                 # Business logic & AI pipelines
│   │   ├── ai_engine.py          # Groq LLM Content Lead & Critic engine
│   │   ├── image_generator.py    # Flux 1024x1024 Ultra-HD creative synthesis
│   │   ├── scraper.py            # Headless crawler for website knowledge synthesis
│   │   ├── doc_parser.py         # pypdf parser for brand collateral (PDF, TXT, MD)
│   │   ├── publisher.py          # Dispatcher for connected social networks
│   │   └── oauth_service.py      # OAuth URL generation & token exchanges
│   └── routers/                  # RESTful API Endpoints
│       ├── auth.py               # /api/auth (signup, login, me)
│       ├── brand.py              # /api/brands (CRUD, crawl, upload docs, strategy)
│       ├── post.py               # /api/posts (generate, approve, reject, request-changes, publish)
│       └── social.py             # /api/social (OAuth connect, list, disconnect)
│
└── frontend/                     # Flutter Luxury Editorial Mobile/Desktop Client
    ├── lib/
    │   ├── core/                 # AppTheme, AppColors, AppTextStyles, SecureStorage, ApiClient
    │   ├── models/               # Strongly-typed models matching backend schemas
    │   ├── providers/            # State management (Auth, Brand, Strategy, Post, Social)
    │   ├── widgets/              # GlowingButton, EditorialBadge, FluxImageCard
    │   └── screens/              # Luxury screen implementations
    │       ├── auth/             # SplashScreen, LoginScreen, SignupScreen
    │       ├── brand/            # BrandSetupScreen, BrandBrainVaultScreen
    │       ├── strategy/         # StrategyBlueprintScreen
    │       ├── inbox/            # PostApprovalInboxScreen (HITL Workflow)
    │       ├── social/           # SocialAccountsHubScreen
    │       └── main_shell.dart   # Brand switcher & bottom navigation
```

---

## ⚡ Key Features

1. **Brand Brain Vault (Zero Hallucination Grounding)**
   - Automatic website crawler parses company value proposition, features, and case studies.
   - Document ingestion accepts PDF pitch decks, whitepapers, and markdown guidelines.
   - Grounded RAG ensures posts reflect real product truths.

2. **Autonomous Strategic Content Lead**
   - Groq-accelerated `qwen/qwen3.8-27b` formulates bespoke 30-day strategy blueprints.
   - Dynamic ICP persona definitions and balanced content pillar allocation (e.g. 40% Authority, 30% Product, 30% Culture).

3. **Flux AI Visual Creatives (1024x1024 Ultra-HD)**
   - Every post is paired with a matching editorial visual generated via Flux.
   - Prompt-engineered for high-impact social cards and clean studio aesthetics.

4. **Human-in-the-Loop (HITL) Safety Guardrails**
   - Posts are strictly held in `PENDING_APPROVAL` status.
   - Founders can **Approve**, **Reject**, **Request AI Changes** (with specific critic feedback), or **Edit copy inline**.
   - Zero unapproved autonomous publishing.

5. **Multi-Tenant JWT Security**
   - Secure founder signup, login, bcrypt password hashing, and bearer token interceptors.

---

## 🚀 Running the Full Stack Locally

### 1. Backend (FastAPI)
```bash
# Activate virtual environment
source venv/bin/activate

# Install dependencies (if needed)
pip install -r requirements.txt

# Start FastAPI server
uvicorn app.main:app --reload --port 8000
```
- Swagger API Docs: `http://localhost:8000/docs`
- Interactive OpenAPI: `http://localhost:8000/redoc`

### 2. Frontend (Flutter)
```bash
cd frontend

# Verify analysis and tests
flutter analyze
flutter test

# Run on macOS Desktop
flutter run -d macos

# Or run on Chrome / Web
flutter run -d chrome
```

---

## 🔒 Environment Configuration (`.env`)

```env
GROQ_API_KEY=gsk_...
JWT_SECRET=super_secret_jwt_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
DATABASE_URL=sqlite:///./social_ai.db
```
