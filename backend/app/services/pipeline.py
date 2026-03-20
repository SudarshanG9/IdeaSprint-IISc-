
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

    # Step 1: Generate base English description
    base_text = generate_description(product)

    # Short-circuit if language is English
    if language == "en":
        translated_text = base_text
    else:
        # Step 2: Translate using Sarvam
        lang_code = LANGUAGE_MAP[language]["code"]
        translated_text = translate_text(base_text, lang_code)

    # Step 3: Convert to speech using Sarvam
    lang_code = LANGUAGE_MAP[language]["code"]
    audio_path = text_to_speech(translated_text, product.id, lang_code)

    # Step 4: Upload to Supabase
    public_url = upload_audio(audio_path, product.id, lang_code)

    # Step 5: Store audio URL in SQLite
    product.audio_url = public_url
    db.commit()

    return {
        "mode": "audio",
        "text": translated_text,
        "audio": public_url
    }