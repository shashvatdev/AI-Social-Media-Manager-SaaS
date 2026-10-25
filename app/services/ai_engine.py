import os
import json
import httpx
from typing import Dict, Any, List, Optional

class AIEngineService:
    @staticmethod
    def generate_posts(
        brand_name: str,
        platform: str,
        tone: Optional[str] = None,
        target_audience: Optional[str] = None,
        content_pillars: Optional[List[str]] = None,
        banned_words: Optional[List[str]] = None,
        knowledge_snippets: Optional[List[str]] = None,
        topic: Optional[str] = None,
        count: int = 3
    ) -> List[Dict[str, Any]]:
        """
        Generates platform-tailored social media posts using brand guidelines and knowledge base.
        """
        api_key = os.getenv("OPENAI_API_KEY", "")

        # Fallback high-quality template generator if no API key is supplied yet
        if not api_key:
            return AIEngineService._generate_smart_fallback(
                brand_name=brand_name,
                platform=platform,
                tone=tone,
                content_pillars=content_pillars,
                topic=topic,
                count=count
            )

        # Real OpenAI Call
        pillars_str = ", ".join(content_pillars) if content_pillars else "Industry Insights, Value Tips"
        banned_str = ", ".join(banned_words) if banned_words else "None"
        context_str = "\n".join(knowledge_snippets[:3]) if knowledge_snippets else "Innovative brand in its domain."

        platform_rules = {
            "LINKEDIN": "Use an engaging 2-line hook before 'see more'. Professional storytelling format with clean line breaks. Include 1 key actionable takeaway and a CTA. 3-4 hashtags.",
            "TWITTER": "Punchy and conversational under 270 characters. Bold first sentence. 1-2 focused hashtags.",
            "INSTAGRAM": "Visually appealing caption with tasteful emojis to break text. Engaging question to spark comments in the community. 10-12 targeted hashtags.",
            "FACEBOOK": "Community-focused, relatable and value-driven with an invitation to discuss."
        }.get(platform.upper(), "Engaging and brand-aligned social post.")

        system_prompt = f"""You are the Lead Social Media Strategist for {brand_name}.
Tone of Voice: {tone or 'Authoritative yet accessible'}
Target Audience: {target_audience or 'Target customers and professionals'}
Content Pillars: {pillars_str}
NEVER USE THESE BANNED WORDS: {banned_str}

Platform Formatting Rules for {platform}:
{platform_rules}

Brand Background & Knowledge Base:
{context_str}

Output strictly valid JSON with this schema:
{{
  "posts": [
    {{
      "content": "formatted post text",
      "hashtags": ["#tag1", "#tag2"],
      "ai_reasoning": "Explain in 1 sentence why this angle works for the brand's audience",
      "suggested_media_prompt": "Prompt for image/creative generator"
    }}
  ]
}}"""

        user_prompt = f"Generate {count} unique {platform} posts" + (f" focused on the topic: '{topic}'" if topic else " cycling through the brand's pillars.")

        try:
            with httpx.Client(timeout=30.0) as client:
                res = client.post(
                    "https://api.openai.com/v1/chat/completions",
                    headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
                    json={
                        "model": "gpt-4o-mini",
                        "response_format": {"type": "json_object"},
                        "messages": [
                            {"role": "system", "content": system_prompt},
                            {"role": "user", "content": user_prompt}
                        ],
                        "temperature": 0.75
                    }
                )
                data = res.json()
                raw_content = data["choices"][0]["message"]["content"]
                parsed = json.loads(raw_content)
                return parsed.get("posts", [])
        except Exception as e:
            # Fallback on network or API failure
            return AIEngineService._generate_smart_fallback(
                brand_name=brand_name,
                platform=platform,
                tone=tone,
                content_pillars=content_pillars,
                topic=topic,
                count=count
            )

    @staticmethod
    def refine_post(
        original_content: str,
        user_feedback: str,
        brand_name: str,
        platform: str
    ) -> str:
        """
        Rewrites an existing post based on user feedback.
        """
        api_key = os.getenv("OPENAI_API_KEY", "")
        if not api_key:
            return f"{original_content}\n\n[Revised based on feedback: '{user_feedback}']"

        try:
            with httpx.Client(timeout=30.0) as client:
                res = client.post(
                    "https://api.openai.com/v1/chat/completions",
                    headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
                    json={
                        "model": "gpt-4o-mini",
                        "messages": [
                            {"role": "system", "content": f"You are a copywriter for {brand_name}. Rewrite the given {platform} post strictly addressing the user's feedback. Return ONLY the new post text."},
                            {"role": "user", "content": f"Original Post:\n{original_content}\n\nFeedback:\n{user_feedback}"}
                        ],
                        "temperature": 0.7
                    }
                )
                data = res.json()
                return data["choices"][0]["message"]["content"].strip()
        except Exception:
            return f"{original_content}\n\n(Updated to reflect: {user_feedback})"

    @staticmethod
    def _generate_smart_fallback(
        brand_name: str,
        platform: str,
        tone: Optional[str],
        content_pillars: Optional[List[str]],
        topic: Optional[str],
        count: int
    ) -> List[Dict[str, Any]]:
        pillar = content_pillars[0] if content_pillars else (topic or "Growth & Efficiency")
        results = []

        if platform.upper() == "LINKEDIN":
            for i in range(count):
                results.append({
                    "content": f"Most companies overlook this one simple reality:\n\nSuccess in {pillar} isn't about working harder—it's about building smarter workflows.\n\nAt {brand_name}, we analyzed why leading teams consistently outperform the rest:\n\n1. Clear intent beats messy execution.\n2. Fast feedback loops create unfair advantages.\n3. Automation frees up high-leverage creative work.\n\nWhat's the biggest bottleneck holding your team back right now?\n\nDrop your thoughts below 👇",
                    "hashtags": [f"#{brand_name.replace(' ', '')}", f"#{pillar.replace(' ', '')}", "#Productivity", "#B2B"],
                    "ai_reasoning": f"Focused on {pillar} with a thought-leadership hook tailored for professional LinkedIn audiences.",
                    "suggested_media_prompt": f"Minimalist, modern editorial graphic representing {pillar} in high-tech corporate style"
                })
        elif platform.upper() == "TWITTER":
            for i in range(count):
                results.append({
                    "content": f"The biggest mistake people make with {pillar}?\n\nTrying to solve with brute force what could be solved with a better system.\n\nSimplicity scales. Complexity fails.",
                    "hashtags": [f"#{pillar.replace(' ', '')}", "#BuildInPublic"],
                    "ai_reasoning": f"Short, punchy contrarian insight designed for high retweets on Twitter/X.",
                    "suggested_media_prompt": "Clean infographic visual contrasting complexity vs simplicity"
                })
        else:
            for i in range(count):
                results.append({
                    "content": f"Redefining how we look at {pillar} ✨\n\nBehind every successful breakthrough is a commitment to doing the fundamentals right every single day.\n\nTell us in the comments: what is your #1 goal this month?",
                    "hashtags": [f"#{brand_name.replace(' ', '')}", f"#{pillar.replace(' ', '')}", "#DailyInspiration"],
                    "ai_reasoning": "Community-first caption with visual prompts for Instagram feed.",
                    "suggested_media_prompt": "High-contrast aesthetic photography representing modern brand lifestyle"
                })

        return results[:count]
