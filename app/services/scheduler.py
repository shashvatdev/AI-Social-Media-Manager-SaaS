import asyncio
import logging
from datetime import datetime
from app.core.database import SessionLocal
from app.models.post import Post, PostStatus
from app.models.social_account import SocialAccount
from app.services.publisher import SocialPublisherService

logger = logging.getLogger("AutonomousScheduler")
logging.basicConfig(level=logging.INFO)

class AutonomousSchedulerDaemon:
    _running = False
    _task = None

    @classmethod
    async def start(cls, check_interval_seconds: int = 30):
        """
        Starts the background autonomous publishing daemon.
        Periodically checks for approved posts whose scheduled_for time has passed,
        and dispatches them safely.
        """
        if cls._running:
            return

        cls._running = True
        logger.info("[Scheduler Daemon] Autonomous Dispatcher started.")
        cls._task = asyncio.create_task(cls._loop(check_interval_seconds))

    @classmethod
    async def stop(cls):
        """Gracefully halts the scheduler daemon."""
        cls._running = False
        if cls._task:
            cls._task.cancel()
            try:
                await cls._task
            except asyncio.CancelledError:
                pass
        logger.info("[Scheduler Daemon] Autonomous Dispatcher stopped.")

    @classmethod
    async def _loop(cls, interval: int):
        while cls._running:
            try:
                await cls.dispatch_due_posts()
            except Exception as e:
                logger.error(f"[Scheduler Daemon Error] {e}", exc_info=True)
            
            await asyncio.sleep(interval)

    @classmethod
    async def dispatch_due_posts(cls):
        """
        Queries approved posts that have reached or passed their scheduled timestamp,
        then publishes them to the brand's connected platform.
        """
        db = SessionLocal()
        try:
            now = datetime.utcnow()
            # Find posts approved/scheduled for current time or earlier
            due_posts = db.query(Post).filter(
                Post.status.in_([PostStatus.APPROVED, "SCHEDULED"]),
                Post.scheduled_for != None,
                Post.scheduled_for <= now
            ).all()

            if not due_posts:
                return

            logger.info(f"[Scheduler Daemon] Found {len(due_posts)} due posts ready for autonomous dispatch.")

            for post in due_posts:
                # Find connected social account
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
                    logger.warning(f"[Scheduler Daemon] No active {post.platform} account for brand {post.brand_id}. Marking post {post.id} as FAILED.")
                    post.status = PostStatus.FAILED
                    post.error_message = f"Autonomous dispatch failed: No active connected {post.platform} account found."
                    db.commit()
                    continue

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
                    logger.info(f"[Scheduler Daemon] Successfully published post {post.id} to {post.platform}!")
                except Exception as pub_err:
                    post.status = PostStatus.FAILED
                    post.error_message = f"Autonomous dispatch error: {str(pub_err)}"
                    db.commit()
                    logger.error(f"[Scheduler Daemon] Failed to publish post {post.id}: {pub_err}")

        finally:
            db.close()
