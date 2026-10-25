import os
import urllib.parse
import urllib.request
import uuid
from typing import Optional

CREATIVES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "uploads", "creatives")
os.makedirs(CREATIVES_DIR, exist_ok=True)

class ImageGeneratorService:
    @staticmethod
    def generate_image_url(prompt: str, brand_name: str = "") -> str:
        """
        Generates a direct ultra-HD Flux image URL tailored for social media creatives.
        """
        enhanced_prompt = (
            f"Professional social media creative for brand '{brand_name}'. "
            f"{prompt}. "
            f"Style: clean modern editorial composition, premium aesthetic, 1024x1024, ultra HD, award-winning visual."
        )
        encoded = urllib.parse.quote(enhanced_prompt)
        # Direct Pollinations Flux URL
        return f"https://image.pollinations.ai/prompt/{encoded}?width=1024&height=1024&nologo=true&model=flux"

    @staticmethod
    def download_and_store_image(prompt: str, brand_name: str = "") -> Optional[str]:
        """
        Generates and saves the creative locally in uploads/creatives/ and returns relative path.
        """
        image_url = ImageGeneratorService.generate_image_url(prompt, brand_name)
        file_id = f"creative_{uuid.uuid4().hex[:12]}.jpg"
        file_path = os.path.join(CREATIVES_DIR, file_id)

        try:
            req = urllib.request.Request(image_url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=45) as resp:
                data = resp.read()
                with open(file_path, "wb") as f:
                    f.write(data)
            return f"/static/creatives/{file_id}"
        except Exception as e:
            print(f"[ImageGen] Download failed: {e}. Falling back to direct URL.")
            return image_url
