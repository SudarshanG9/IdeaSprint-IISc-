import requests

SARVAM_API_KEY = 'sk_627h8h2i_f4Hz7iqSYb2BPXxu5himKiQf'

def translate_text(text, target_language):
    url = "https://api.sarvam.ai/v1/translate"
    headers = {
        "Authorization": f"Bearer {SARVAM_API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "input": text,
        "source_language_code": "en",
        "target_language_code": target_lang,
        "mode": "formal"  
    }


    response = requests.post(url, headers=headers, json=data)
    return response.json()["translated_text"]

    
