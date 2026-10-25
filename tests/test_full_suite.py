import unittest
from datetime import datetime, timedelta
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.user import User
from app.models.brand import Brand
from app.models.post import Post, PostStatus
from app.models.social_account import SocialAccount
from app.services.scheduler import AutonomousSchedulerDaemon

class EnterpriseSocialAITestSuite(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)
        cls.db = SessionLocal()

        # Clean/Setup test founder user
        cls.test_email = f"founder_{int(datetime.utcnow().timestamp())}@example.com"
        cls.test_password = "SecretPassword123!"

    @classmethod
    def tearDownClass(cls):
        cls.db.close()

    def test_01_health_check(self):
        """Verifies health check endpoint returns 200 with platform architecture."""
        res = self.client.get("/health")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["status"], "healthy")
        self.assertEqual(data["llm_provider"], "Groq")
        self.assertEqual(data["approval_system"], "Human-In-The-Loop (Enforced)")

    def test_02_auth_signup_and_login(self):
        """Verifies founder registration and JWT bearer token issuance."""
        # 1. Signup
        signup_res = self.client.post("/api/auth/signup", json={
            "email": self.test_email,
            "password": self.test_password,
            "full_name": "Test Founder"
        })
        self.assertEqual(signup_res.status_code, 201)
        signup_data = signup_res.json()
        self.assertIn("access_token", signup_data)
        self.assertEqual(signup_data["user"]["email"], self.test_email)

        # 2. Login
        login_res = self.client.post("/api/auth/login", json={
            "email": self.test_email,
            "password": self.test_password
        })
        self.assertEqual(login_res.status_code, 200)
        login_data = login_res.json()
        self.assertIn("access_token", login_data)
        self.__class__.token = login_data["access_token"]
        self.__class__.headers = {"Authorization": f"Bearer {self.__class__.token}"}

    def test_03_brand_creation(self):
        """Verifies brand onboarding with tone, pillars, and audience."""
        res = self.client.post("/api/brands", headers=self.headers, json={
            "name": "Acme Autonomous AI",
            "website_url": "https://acme-ai.example.com",
            "industry": "B2B SaaS",
            "tone_of_voice": "Authoritative, technical, no fluff",
            "target_audience": "CTOs and Series A Founders",
            "content_pillars": ["Product Deconstructions", "Engineering Culture"],
            "banned_words": ["synergy", "paradigm shift"]
        })
        self.assertEqual(res.status_code, 201)
        data = res.json()
        self.assertEqual(data["name"], "Acme Autonomous AI")
        self.__class__.brand_id = data["id"]

    def test_04_brand_analytics(self):
        """Verifies real-time analytics KPI computation."""
        res = self.client.get(f"/api/brands/{self.brand_id}/analytics")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["brand_id"], self.brand_id)
        self.assertIn("approval_rate", data)
        self.assertIn("avg_quality_score", data)

    def test_05_scheduler_and_autonomous_dispatch(self):
        """Verifies scheduling a post and autonomous background execution."""
        # Create a mock social account for publishing
        account = SocialAccount(
            brand_id=self.brand_id,
            platform="LINKEDIN",
            account_handle="@acmetest",
            access_token="mock_token_for_testing",
            is_active=True
        )
        self.db.add(account)
        self.db.commit()
        self.db.refresh(account)

        # Create a post scheduled in the past (due right now)
        due_time = datetime.utcnow() - timedelta(minutes=5)
        post = Post(
            brand_id=self.brand_id,
            platform="LINKEDIN",
            content="Autonomous SaaS engineering deconstruction post.",
            pillar="Product Deconstructions",
            funnel_stage="AUTHORITY",
            quality_score="9.7/10",
            status=PostStatus.SCHEDULED,
            scheduled_for=due_time
        )
        self.db.add(post)
        self.db.commit()
        self.db.refresh(post)

        # Run scheduler dispatch
        import asyncio
        asyncio.run(AutonomousSchedulerDaemon.dispatch_due_posts())

        # Verify post is now PUBLISHED
        self.db.refresh(post)
        self.assertEqual(post.status, PostStatus.PUBLISHED)
        self.assertIsNotNone(post.published_at)
        self.assertIsNotNone(post.platform_post_id)

    def test_06_brand_export_report(self):
        """Verifies generating an executive Markdown report of the strategy & schedule."""
        res = self.client.get(f"/api/brands/{self.brand_id}/export")
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["brand_name"], "Acme Autonomous AI")
        self.assertIn("report_markdown", data)
        self.assertIn("30-Day Editorial Content Blueprint", data["report_markdown"])
        self.assertGreaterEqual(data["total_posts"], 1)

    def test_07_brand_brain_rag_query(self):
        """Verifies grounded RAG synthesis from ingested knowledge assets."""
        res = self.client.post(f"/api/brands/{self.brand_id}/brain/query", json={
            "question": "What is our core engineering focus?"
        })
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["brand_id"], self.brand_id)
        self.assertIn("answer", data)
        self.assertTrue(len(data["answer"]) > 10)
        self.assertIn("cited_sources", data)

if __name__ == "__main__":
    unittest.main()
