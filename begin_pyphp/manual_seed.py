import os
from dotenv import load_dotenv
from backend.common.database import SessionLocal
from backend.common.seeder import seed_all

def run_seed():
    load_dotenv(".env", override=True)
    try:
        print("Starting manual seed process...")
        seed_all()
        print("Manual seed process completed successfully.")
    except Exception as e:
        print(f"CRITICAL ERROR during manual seed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        pass

if __name__ == "__main__":
    run_seed()
