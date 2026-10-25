import io
from pypdf import PdfReader

class DocumentParserService:
    @staticmethod
    def extract_text(file_bytes: bytes, filename: str) -> str:
        """
        Extracts clean text from uploaded PDF, TXT or Markdown files.
        """
        lower_name = filename.lower()

        if lower_name.endswith(".pdf"):
            reader = PdfReader(io.BytesIO(file_bytes))
            text_parts = []
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text_parts.append(page_text.strip())
            return "\n\n".join(text_parts)

        # For text / markdown
        try:
            return file_bytes.decode("utf-8").strip()
        except UnicodeDecodeError:
            return file_bytes.decode("latin-1", errors="ignore").strip()
