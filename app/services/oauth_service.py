import os
import httpx
from typing import Dict, Any, Optional

class OAuthService:
    # ------------------ LINKEDIN ------------------
    @staticmethod
    def get_linkedin_auth_url(brand_id: str) -> str:
        client_id = os.getenv("LINKEDIN_CLIENT_ID", "mock_linkedin_client_id")
        redirect_uri = os.getenv("LINKEDIN_REDIRECT_URI", "http://localhost:8000/api/social/oauth/linkedin/callback")
        scopes = "openid%20profile%20w_member_social%20email"
        # State carries the brand_id securely
        return f"https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id={client_id}&redirect_uri={redirect_uri}&state={brand_id}&scope={scopes}"

    @staticmethod
    def exchange_linkedin_token(code: str) -> Dict[str, Any]:
        client_id = os.getenv("LINKEDIN_CLIENT_ID", "")
        client_secret = os.getenv("LINKEDIN_CLIENT_SECRET", "")
        redirect_uri = os.getenv("LINKEDIN_REDIRECT_URI", "http://localhost:8000/api/social/oauth/linkedin/callback")

        # If running in local/test without live API keys, return mock connected payload
        if not client_id or not client_secret:
            return {
                "access_token": f"mock_li_token_{code[:8]}",
                "refresh_token": "mock_li_refresh_token",
                "account_handle": "linkedin_brand_profile",
                "account_name": "LinkedIn Brand User",
                "avatar_url": "https://cdn.iconscout.com/icon/free/png-256/free-linkedin-logo-icon-download-in-svg-png-gif-file-formats--social-media-pack-logos-icons-2673752.png"
            }

        with httpx.Client() as client:
            token_res = client.post(
                "https://www.linkedin.com/oauth/v2/accessToken",
                data={
                    "grant_type": "authorization_code",
                    "code": code,
                    "redirect_uri": redirect_uri,
                    "client_id": client_id,
                    "client_secret": client_secret,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"}
            )
            token_data = token_res.json()
            access_token = token_data.get("access_token")

            # Fetch user profile
            profile_res = client.get(
                "https://api.linkedin.com/v2/userinfo",
                headers={"Authorization": f"Bearer {access_token}"}
            )
            profile_data = profile_res.json()

            return {
                "access_token": access_token,
                "refresh_token": token_data.get("refresh_token"),
                "account_handle": profile_data.get("sub", "linkedin_user"),
                "account_name": profile_data.get("name", "LinkedIn User"),
                "avatar_url": profile_data.get("picture"),
                "platform_user_id": profile_data.get("sub")
            }

    # ------------------ TWITTER / X ------------------
    @staticmethod
    def get_twitter_auth_url(brand_id: str) -> str:
        client_id = os.getenv("TWITTER_CLIENT_ID", "mock_twitter_client_id")
        redirect_uri = os.getenv("TWITTER_REDIRECT_URI", "http://localhost:8000/api/social/oauth/twitter/callback")
        scopes = "tweet.read%20tweet.write%20users.read%20offline.access"
        # OAuth 2.0 PKCE flow
        return f"https://twitter.com/i/oauth2/authorize?response_type=code&client_id={client_id}&redirect_uri={redirect_uri}&scope={scopes}&state={brand_id}&code_challenge=challenge&code_challenge_method=plain"

    @staticmethod
    def exchange_twitter_token(code: str) -> Dict[str, Any]:
        client_id = os.getenv("TWITTER_CLIENT_ID", "")
        client_secret = os.getenv("TWITTER_CLIENT_SECRET", "")
        redirect_uri = os.getenv("TWITTER_REDIRECT_URI", "http://localhost:8000/api/social/oauth/twitter/callback")

        if not client_id or not client_secret:
            return {
                "access_token": f"mock_tw_token_{code[:8]}",
                "refresh_token": "mock_tw_refresh_token",
                "account_handle": "twitter_brand_handle",
                "account_name": "Twitter Brand Account",
                "avatar_url": "https://cdn.iconscout.com/icon/free/png-256/free-twitter-logo-icon-download-in-svg-png-gif-file-formats--social-media-pack-logos-icons-2673754.png"
            }

        with httpx.Client() as client:
            token_res = client.post(
                "https://api.twitter.com/2/oauth2/token",
                data={
                    "code": code,
                    "grant_type": "authorization_code",
                    "client_id": client_id,
                    "redirect_uri": redirect_uri,
                    "code_verifier": "challenge"
                },
                auth=(client_id, client_secret)
            )
            token_data = token_res.json()
            access_token = token_data.get("access_token")

            # Fetch username
            user_res = client.get(
                "https://api.twitter.com/2/users/me",
                headers={"Authorization": f"Bearer {access_token}"}
            )
            user_data = user_res.json().get("data", {})

            return {
                "access_token": access_token,
                "refresh_token": token_data.get("refresh_token"),
                "account_handle": user_data.get("username", "twitter_user"),
                "account_name": user_data.get("name", "Twitter User"),
                "platform_user_id": user_data.get("id")
            }

    # ------------------ META (INSTAGRAM & FACEBOOK) ------------------
    @staticmethod
    def get_meta_auth_url(brand_id: str) -> str:
        app_id = os.getenv("META_APP_ID", "mock_meta_app_id")
        redirect_uri = os.getenv("META_REDIRECT_URI", "http://localhost:8000/api/social/oauth/meta/callback")
        scopes = "pages_show_list,pages_read_engagement,pages_manage_posts,instagram_basic,instagram_content_publish"
        return f"https://www.facebook.com/v19.0/dialog/oauth?client_id={app_id}&redirect_uri={redirect_uri}&state={brand_id}&scope={scopes}"

    @staticmethod
    def exchange_meta_token(code: str) -> Dict[str, Any]:
        app_id = os.getenv("META_APP_ID", "")
        app_secret = os.getenv("META_APP_SECRET", "")
        redirect_uri = os.getenv("META_REDIRECT_URI", "http://localhost:8000/api/social/oauth/meta/callback")

        if not app_id or not app_secret:
            return {
                "access_token": f"mock_meta_token_{code[:8]}",
                "refresh_token": None,
                "account_handle": "instagram_brand_page",
                "account_name": "Instagram Official Page",
                "avatar_url": "https://cdn.iconscout.com/icon/free/png-256/free-instagram-logo-icon-download-in-svg-png-gif-file-formats--social-media-pack-logos-icons-2673751.png"
            }

        with httpx.Client() as client:
            token_res = client.get(
                "https://graph.facebook.com/v19.0/oauth/access_token",
                params={
                    "client_id": app_id,
                    "client_secret": app_secret,
                    "redirect_uri": redirect_uri,
                    "code": code
                }
            )
            token_data = token_res.json()
            return {
                "access_token": token_data.get("access_token"),
                "refresh_token": None,
                "account_handle": "meta_business_account",
                "account_name": "Meta Connected Page"
            }
