import httpx
from bs4 import BeautifulSoup
from typing import Dict, Any, List

class ScraperService:
    @staticmethod
    def scrape_url(url: str) -> Dict[str, Any]:
        """
        Scrapes a target website URL and extracts brand-relevant information.
        """
        target_url = url if url.startswith("http") else f"https://{url}"
        
        headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        }

        with httpx.Client(follow_redirects=True, timeout=15.0) as client:
            response = client.get(target_url, headers=headers)
            response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")

        # Remove unwanted tags
        for element in soup(["script", "style", "nav", "footer", "iframe", "svg", "noscript"]):
            element.decompose()

        # Extract title & description
        title = ""
        if soup.title and soup.title.string:
            title = soup.title.string.strip()
        elif soup.find("meta", property="og:title"):
            title = soup.find("meta", property="og:title").get("content", "").strip()

        description = ""
        meta_desc = soup.find("meta", attrs={"name": "description"}) or soup.find("meta", property="og:description")
        if meta_desc:
            description = meta_desc.get("content", "").strip()

        # Extract key headings
        headings: List[str] = []
        for tag in soup.find_all(["h1", "h2", "h3"]):
            text = " ".join(tag.get_text().split())
            if text and len(text) > 4 and len(text) < 120 and text not in headings:
                headings.append(text)

        # Extract social links
        social_links: List[str] = []
        for a in soup.find_all("a", href=True):
            href = a["href"].lower()
            if any(p in href for p in ["twitter.com", "x.com", "linkedin.com", "instagram.com", "facebook.com"]):
                if a["href"] not in social_links:
                    social_links.append(a["href"])

        # Extract main readable paragraphs
        paragraphs: List[str] = []
        for p in soup.find_all("p"):
            text = " ".join(p.get_text().split())
            if len(text) > 35:
                paragraphs.append(text)

        clean_text = "\n\n".join(paragraphs[:25])[:4000]

        return {
            "title": title,
            "description": description,
            "headings": headings[:15],
            "social_links": social_links,
            "extracted_text": clean_text
        }
