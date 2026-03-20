import os
from dotenv import load_dotenv

load_dotenv(override=True)

SARVAM_API_KEY = os.getenv("SARVAM_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
FRONTEND_URL = os.getenv("FRONTEND_URL", "https://frontend.com")
