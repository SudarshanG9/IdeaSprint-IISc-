import requests
from app.config import SARVAM_API_KEY


def translate_text(text, target_language):
    url = "https://api.sarvam.ai/translate"
    headers = {
        "api-subscription-key": SARVAM_API_KEY,
        "Content-Type": "application/json"
    }

    data = {
        "input": text,
        "source_language_code": "en-IN",
        "target_language_code": target_language,
        "mode": "formal",
        "speaker": "meera"
    }

    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    return response.json()["translated_text"]
