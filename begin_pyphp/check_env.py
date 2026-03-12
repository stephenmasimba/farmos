from backend.common.config import settings
import os
from dotenv import load_dotenv

def check_settings():
    print(f"OS ENV DATABASE_URL: {os.environ.get('DATABASE_URL')}")
    print(f"Settings DATABASE_URL: {settings.DATABASE_URL}")

if __name__ == "__main__":
    check_settings()