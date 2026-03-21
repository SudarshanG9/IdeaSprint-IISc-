
from app.services.generator import generate_description
from app.services.translator import translate_text
from app.services.tts import text_to_speech
from app.services.storage import upload_audio



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

def process_product(product, db, language="en"):
    primary_text = product.description
    detailed_text = product.detailed_description or ""

    if language == "en":
        translated_primary = primary_text
        translated_detailed = detailed_text
    else:
        lang_code = LANGUAGE_MAP[language]["code"]
        translated_primary = translate_text(primary_text, lang_code)
        translated_detailed = translate_text(detailed_text, lang_code) if detailed_text else ""

    lang_code = LANGUAGE_MAP[language]["code"] if language != "en" else "en-IN"

    # Convert to speech & Upload PRIMARY
    primary_audio_path = text_to_speech(translated_primary, f"{product.id}_primary", lang_code)
    primary_public_url = upload_audio(primary_audio_path, f"{product.id}_primary", lang_code)

    # Convert to speech & Upload DETAILED
    detailed_public_url = None
    if translated_detailed:
        detailed_audio_path = text_to_speech(translated_detailed, f"{product.id}_detailed", lang_code)
        detailed_public_url = upload_audio(detailed_audio_path, f"{product.id}_detailed", lang_code)

    product.audio_url = primary_public_url
    product.detailed_audio_url = detailed_public_url
    db.commit()

    return {
        "mode": "audio",
        "text": translated_primary,
        "audio": primary_public_url,
        "detailed_text": translated_detailed,
        "detailed_audio": detailed_public_url
    }