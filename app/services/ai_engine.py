import os
import json
import re
from typing import Dict, Any, List, Optional
from groq import Groq
from dotenv import load_dotenv

load_dotenv()

GROQ_MODEL = "qwen/qwen3.8-27b"

PLATFORM_PLAYBOOKS = {
    "LINKEDIN": """
LINKEDIN VIRAL & AUTHORITY FORMULA:
- Hook (Line 1-2): Scroll-stopping opener before the 'see more' cut. Must trigger curiosity, challenge common wisdom, or present a staggering metric.
- Structure: Short, punchy paragraphs (1-2 sentences maximum). Aggressive line breaks for readability on mobile.
- Body: Actionable breakdown, framework, or real-world case study. Deliver immediate utility.
- Formatting: Bullet points or numbered lists where applicable.
- Call to Action (CTA): Clear, frictionless closing question that invites authentic professional debate in the comments.
- Hashtags: 3-4 targeted, industry-specific hashtags at the very bottom.
- Style: Professional, sharp, authoritative. No corporate buzzword soup.
""",
    "INSTAGRAM": """
INSTAGRAM HIGH-ENGAGEMENT CAPTION FORMULA:
- Hook (Line 1): High-impact opening headline with an emoji to grab visual attention.
- Body: Conversational narrative, quick tips, or micro-story. Use aesthetic spacing.
- Engagement Trigger: Ask a direct question ("Save this for later" or "Drop a 🔥 if you agree").
- Hashtags: 8-12 niche-targeted hashtags placed at the bottom.
- Style: Aesthetic, inspiring, human, authentic.
""",
    "TWITTER": """
TWITTER / X ENGAGEMENT FORMULA:
- Hook: Bold contrarian claim or striking framework under 270 characters.
- Tone: High-signal, zero fluff.
- Max 2 hashtags.
"""
}

class AIEngineService:
    @staticmethod
    def _get_client() -> Groq:
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ValueError("GROQ_API_KEY is not configured in .env")
        return Groq(api_key=api_key)

    @staticmethod
    def _clean_json_response(raw_text: str) -> Dict[str, Any]:
        """Strips markdown code blocks and safely parses JSON."""
        cleaned = re.sub(r"^```(?:json)?\s*", "", raw_text.strip(), flags=re.MULTILINE)
        cleaned = re.sub(r"\s*```$", "", cleaned.strip(), flags=re.MULTILINE)
        
        # Extract first { to last }
        match = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if match:
            cleaned = match.group(0)

        try:
            return json.loads(cleaned, strict=False)
        except json.JSONDecodeError:
            # Handle potential unescaped double quotes inside values or missing closures
            for fix in ["}", "\"]}", "\"}]}", "\"}]}}"]:
                try:
                    return json.loads(cleaned + fix, strict=False)
                except Exception:
                    continue
            raise

    @staticmethod
    def generate_brand_strategy(
        brand_name: str,
        website_url: Optional[str] = None,
        industry: Optional[str] = None,
        initial_tone: Optional[str] = None,
        initial_audience: Optional[str] = None,
        knowledge_snippets: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        AI Content Lead Blueprint: Analyzes all ingested brand facts and generates a full 360-degree
        content strategy, ICP breakdown, pillar allocation, and platform playbooks.
        """
        client = AIEngineService._get_client()
        context_corpus = "\n\n".join(knowledge_snippets[:6]) if knowledge_snippets else "No raw docs uploaded yet."

        prompt = f"""You are the Chief Social Media Strategist for "{brand_name}".
Analyze the brand details and formulate a crisp, high-impact 30-Day Brand Social Media Strategy Blueprint.

BRAND DETAILS:
- Website: {website_url or 'N/A'}
- Industry: {industry or 'High-Growth Tech/Business'}
- Tone: {initial_tone or 'Authoritative, innovative, high-signal'}
- Audience: {initial_audience or 'Decision-makers and target customers'}

BRAND KNOWLEDGE BASE:
{context_corpus}

Return STRICTLY valid JSON with no conversational text:
{{
  "positioning_statement": "Sharp 2-sentence market positioning and unique unfair advantage.",
  "target_personas": [
    {{
      "name": "Primary ICP (e.g. The Overwhelmed VP of Engineering)",
      "job_title": "Primary titles",
      "pain_points": ["Top pain point 1", "Top pain point 2"],
      "core_desires": ["Primary goal 1", "Primary goal 2"],
      "objections": ["Key skepticism"]
    }}
  ],
  "tone_guidelines": {{
    "voice_traits": ["Direct", "Data-backed", "Pragmatic"],
    "do_rules": ["Use specific numbers and frameworks", "Lead with strong hooks"],
    "dont_rules": ["No generic motivational quotes", "No corporate buzzwords"],
    "banned_cliches": ["In today's fast-paced world", "Game changer", "Synergy", "Unlock potential"]
  }},
  "content_pillars": [
    {{
      "name": "Deconstructions & Industry Data",
      "target_percentage": 40,
      "focus_theme": "High-signal technical/business breakdowns",
      "example_angles": ["Angle 1", "Angle 2"]
    }},
    {{
      "name": "Actionable How-To Frameworks",
      "target_percentage": 35,
      "focus_theme": "Immediately usable workflow playbooks",
      "example_angles": ["Angle 1", "Angle 2"]
    }},
    {{
      "name": "Social Proof & Metrics",
      "target_percentage": 25,
      "focus_theme": "Real case studies and cost/time savings",
      "example_angles": ["Angle 1"]
    }}
  ],
  "funnel_mix": {{
    "awareness_percentage": 40,
    "authority_percentage": 35,
    "conversion_percentage": 25
  }},
  "platform_playbooks": {{
    "linkedin": "Authoritative thought leadership, strong 2-line hooks, structured takeaways, clear CTA",
    "instagram": "Visual frameworks, aesthetic carousels, concise actionable captions"
  }},
  "weekly_cadence": {{
    "recommended_posts_per_week": 4,
    "best_posting_days": ["Tuesday", "Wednesday", "Thursday"],
    "optimal_time_windows": ["08:30 AM - 10:00 AM", "04:30 PM - 06:00 PM"]
  }}
}}
"""
        response = client.chat.completions.create(
            model=GROQ_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=900
        )
        return AIEngineService._clean_json_response(response.choices[0].message.content)

    @staticmethod
    def generate_posts(
        brand_name: str,
        platform: str,
        strategy: Optional[Dict[str, Any]] = None,
        tone: Optional[str] = None,
        target_audience: Optional[str] = None,
        content_pillars: Optional[List[str]] = None,
        banned_words: Optional[List[str]] = None,
        knowledge_snippets: Optional[List[str]] = None,
        topic: Optional[str] = None,
        count: int = 1
    ) -> List[Dict[str, Any]]:
        """
        Generates brand-tailored posts governed by the strategic plan and brand knowledge.
        Applies a quality critic review score to every post.
        """
        client = AIEngineService._get_client()
        platform_clean = platform.upper().strip()
        playbook = PLATFORM_PLAYBOOKS.get(platform_clean, PLATFORM_PLAYBOOKS["LINKEDIN"])

        strategy_context = ""
        if strategy:
            strategy_context = f"""
APPROVED BRAND STRATEGY:
- Positioning: {strategy.get('positioning_statement', '')}
- Target Personas: {json.dumps(strategy.get('target_personas', []))}
- Tone Guidelines: {json.dumps(strategy.get('tone_guidelines', {}))}
- Pillars: {json.dumps(strategy.get('content_pillars', []))}
- Funnel Mix: {json.dumps(strategy.get('funnel_mix', {}))}
"""

        knowledge_str = "\n\n".join(knowledge_snippets[:5]) if knowledge_snippets else "No extra documents."

        system_prompt = f"""You are the Lead Content Creator & Copywriter for "{brand_name}".
Write {count} viral-grade, high-converting {platform_clean} post.

{strategy_context}

RAW BRAND FACTS (incorporate real metrics and facts from here):
{knowledge_str}

{playbook}

RULES:
1. Every post MUST have an arresting 2-line hook that creates an irresistible urge to read more.
2. Zero fluff, zero generic clichés (never say 'In today's fast-paced world', 'Game changer', 'Dive in').
3. Provide a creative image generation prompt for a matching modern high-res graphic.
4. Return valid JSON only. Properly escape newlines inside the content string as \n.

Return STRICTLY valid JSON with no preamble:
{{
  "posts": [
    {{
      "content": "formatted post text with spacing, hooks, value points, and CTA",
      "hashtags": ["#tag1", "#tag2", "#tag3"],
      "pillar": "Specific content pillar name",
      "funnel_stage": "AWARENESS or AUTHORITY or CONVERSION",
      "hook_angle": "Description of the hook psychology used",
      "ai_reasoning": "Why this specific topic and angle resonates with the target audience",
      "suggested_media_prompt": "Ultra-detailed visual prompt for 3D/editorial image generator",
      "quality_score": "Score out of 10, e.g. 9.4/10",
      "critic_notes": "Critique on why hook and value delivery meets top-tier standards"
    }}
  ]
}}
"""
        user_prompt = (
            f"Generate {count} distinct {platform_clean} post"
            + (f" focused on: '{topic}'" if topic else " cycling through the strategic pillars.")
        )

        response = client.chat.completions.create(
            model=GROQ_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.75,
            max_tokens=800
        )
        parsed = AIEngineService._clean_json_response(response.choices[0].message.content)
        return parsed.get("posts", [])

    @staticmethod
    def refine_post(
        original_content: str,
        user_feedback: str,
        brand_name: str,
        platform: str
    ) -> str:
        """
        Rewrites post incorporating specific human feedback while preserving voice and structure.
        """
        client = AIEngineService._get_client()
        prompt = f"""You are the Senior Editor for "{brand_name}".
Rewrite this {platform} post strictly incorporating the user's revision notes.
Elevate the hook, sharpen the value, and follow platform formatting.

ORIGINAL POST:
{original_content}

USER REVISION NOTES:
{user_feedback}

Output ONLY the rewritten post text. Do not add conversational intro or outro.
"""
        response = client.chat.completions.create(
            model=GROQ_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=800
        )
        return response.choices[0].message.content.strip()
