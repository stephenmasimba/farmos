from pydantic_settings import BaseSettings, SettingsConfigDict
from dotenv import load_dotenv
import os

# Find the project root (.env is there)
basedir = os.path.abspath(os.path.dirname(__file__))
while not os.path.exists(os.path.join(basedir, '.env')) and basedir != os.path.dirname(basedir):
    basedir = os.path.dirname(basedir)

env_path = os.path.join(basedir, '.env')
load_dotenv(env_path, override=True)

class Settings(BaseSettings):
    SECRET_KEY: str = os.getenv("SECRET_KEY", "fallback_secret")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    DATABASE_URL: str = os.getenv("DATABASE_URL", "mysql+pymysql://root:@localhost/begin_masimba_farm")
    API_KEY: str = os.getenv("API_KEY", "local-dev-key")

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
