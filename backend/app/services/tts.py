import requests
import os
import base64
from app.config import SARVAM_API_KEY


def text_to_speech(text, product_id, language):

    os.makedirs("storage/audio", exist_ok=True)

    file_path = f"storage/audio/{product_id}_{language}.wav"

    # caching
    if os.path.exists(file_path):
        return file_path

    url = "https://api.sarvam.ai/text-to-speech"

    headers = {
        "Authorization": f"Bearer {SARVAM_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "text": text,
        "language_code": language,
        "speaker": "anushka"
    }

    response = requests.post(url, json=data, headers=headers)
    response.raise_for_status()

    # Sarvam returns base64 encoded audio in JSON
    audio_base64 = response.json().get("audios", [])[0]
    audio_bytes = base64.b64decode(audio_base64)

    with open(file_path, "wb") as f:
        f.write(audio_bytes)

    return file_path