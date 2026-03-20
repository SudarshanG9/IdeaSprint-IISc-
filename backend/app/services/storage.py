from app.services.supabase import supabase

BUCKET_NAME = "audio-files"


def upload_audio(file_path, product_id, language):

    file_name = f"{product_id}_{language}.mp3"

    # Check if file already exists
    existing = supabase.storage.from_(BUCKET_NAME).list()
    for file in existing:
        if file.get("name") == file_name:
            return supabase.storage.from_(BUCKET_NAME).get_public_url(file_name)

    with open(file_path, "rb") as f:
        supabase.storage.from_(BUCKET_NAME).upload(
            file_name,
            f,
            {"content-type": "audio/mpeg"}
        )

    # public URL
    public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(file_name)

    return public_url