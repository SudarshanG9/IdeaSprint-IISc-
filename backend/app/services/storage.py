from app.services.supabase import supabase
import os

BUCKET_NAME = "audio-files"

def upload_audio(file_path, product_id, language):

    file_name = f"{product_id}_{language}.mp3"


    existing = supabase.storage.from_(BUCKET_NAME).list()
    for file in existing:
        if file.name == file_name:
            return file.public_url
        
    with open(file_path, "rb") as f:
        supabase.storage.from_(BUCKET_NAME).upload(
            file_name,
            f,
            {"content-type": "audio/mpeg"}
        )

    # public URL
    public_url = f"{supabase.storage.from_(BUCKET_NAME).get_public_url(file_name)}"

    return public_url