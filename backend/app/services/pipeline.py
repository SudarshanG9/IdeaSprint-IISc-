
from app.services.generator import generate_description
from app.services.translator import translate_text
from app.services.tts import text_to_speech


LANGUAGE_MAP = {
    "en": {
        "name": "English",
        "code": "en-IN"
    },
    "hi": {
        "name": "Hindi",
        "code": "hi-IN"
    },
    "ta": {
        "name": "Tamil",
        "code": "ta-IN"
    },
    "te": {
        "name": "Telugu",
        "code": "te-IN"
    },
    "kn": {
        "name": "Kannada",
        "code": "kn-IN"
    },
    "ml": {
        "name": "Malayalam",
        "code": "ml-IN"
    },
    "bn": {
        "name": "Bengali",
        "code": "bn-IN"
    },
    "mr": {
        "name": "Marathi",
        "code": "mr-IN"
    },
    "gu": {
        "name": "Gujarati",
        "code": "gu-IN"
    },
    "pa": {
        "name": "Punjabi",
        "code": "pa-IN"
    },
    "or": {
        "name": "Odia",
        "code": "or-IN"
    },
    "as": {
        "name": "Assamese",
        "code": "as-IN"
    },
    "ur": {
        "name": "Urdu",
        "code": "ur-IN"
    }
}

def process_product(product, language="en"):

    # Step 1: Generate base English description
    base_text = generate_description(product)

    # Step 2: Translate using Sarvam
    language = LANGUAGE_MAP[language]["code"]
    translated_text = translate_text(base_text, language)

    # Step 3: Convert to speech using Sarvam
    audio_path = text_to_speech(translated_text, product.id, language)

    return {
        "text": translated_text,
        "audio": audio_path
    }