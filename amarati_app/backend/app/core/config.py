from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "Amarati API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    # Database — SQLite
    DATABASE_URL: str = "sqlite+aiosqlite:///./amarati.db"

    # Security
    SECRET_KEY: str = "changethis-secret-key-for-amarati-development"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    model_config = SettingsConfigDict(env_file=".env")


settings = Settings()
