"""
Production-grade configuration management using pydantic-settings.
"""
from functools import lru_cache
from typing import List, Union
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # Supabase config
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: str
    SUPABASE_JWT_SECRET: str

    # Firebase config (optional)
    FCM_SERVER_KEY: str = ""
    FIREBASE_CREDENTIALS_PATH: str = "firebase-credentials.json"

    # App config
    SECRET_KEY: str
    ENVIRONMENT: str = "development"
    MAX_UPLOAD_SIZE_MB: int = 50
    ALLOWED_ORIGINS: Union[str, List[str]] = ["*"]
    UPLOAD_TEMP_DIR: str = "./temp_uploads"
    LOG_LEVEL: str = "INFO"

    @field_validator("ALLOWED_ORIGINS")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str):
            return [i.strip() for i in v.split(",") if i.strip()]
        return v

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() == "production"

    @property
    def is_development(self) -> bool:
        return self.ENVIRONMENT.lower() in ("development", "dev")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

@lru_cache
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
