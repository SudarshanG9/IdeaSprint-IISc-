import requests
import os

SARVAM_API_KEY = "sk_627h8h2i_f4Hz7iqSYb2BPXxu5himKiQf"

def text_to_speech(text, product_id, language):

    os.makedirs("storage/audio", exist_ok=True)

    file_path = f"storage/audio/{product_id}_{language}.mp3"

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
        "speaker": "female" 
    }

    response = requests.post(url, json=data, headers=headers)

    with open(file_path, "wb") as f:
        f.write(response.content)

    return file_path