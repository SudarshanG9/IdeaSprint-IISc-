import requests
from app.config import SARVAM_API_KEY
import textwrap

def translate_text(text, target_language):
    url = "https://api.sarvam.ai/translate"
    headers = {
        "api-subscription-key": SARVAM_API_KEY,
        "Content-Type": "application/json"
    }

    # Split text into chunks to avoid Sarvam's 500 character limit
    # We chunk by sentences approximately, keeping them under 400 chars.
    chunks = textwrap.wrap(text, width=400, break_long_words=False, break_on_hyphens=False)
    translated_pieces = []

    for chunk in chunks:
        if not chunk.strip():
            continue
        data = {
            "input": chunk,
            "source_language_code": "en-IN",
            "target_language_code": target_language,
            "mode": "formal",
            "speaker": "meera"
        }
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()
        translated_pieces.append(response.json()["translated_text"])

    return " ".join(translated_pieces)
