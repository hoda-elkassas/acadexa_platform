"""
Reads all environment variables using pydantic-settings.
Exports a single 'settings' object used throughout the app.
"""
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Supabase
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: str

    # Firebase (optional)
    FCM_SERVER_KEY: str = ""
    FIREBASE_CREDENTIALS_PATH: str = "firebase-credentials.json"

    # App
    SECRET_KEY: str = "change-me"
    ENVIRONMENT: str = "development"
    MAX_UPLOAD_SIZE_MB: int = 50
    ALLOWED_ORIGINS: List[str] = ["*"]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
