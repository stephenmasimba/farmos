#!/usr/bin/env python3
"""
Begin Masimba FarmOS Backend Startup Script
"""

import os
import sys
import subprocess
import time
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent / "begin_pyphp" / "backend"
sys.path.insert(0, str(backend_dir))

def check_environment():
    """Check if environment is properly configured"""
    print("🔍 Checking environment configuration...")
    
    # Check .env file
    env_file = Path(__file__).parent / ".env"
    if not env_file.exists():
        print("❌ .env file not found. Creating default configuration...")
        create_default_env()
    
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    # Check critical variables
    required_vars = ['DATABASE_URL', 'API_KEY', 'SECRET_KEY']
    missing_vars = []
    
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print(f"❌ Missing environment variables: {', '.join(missing_vars)}")
        return False
    
    print("✅ Environment configuration OK")
    return True

def create_default_env():
    """Create default .env file"""
    env_content = """# Begin Masimba FarmOS Environment Configuration

# Database Settings
DATABASE_URL=mysql+pymysql://root:@localhost/begin_masimba_farm
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=begin_masimba_farm
DATABASE_USER=root
DATABASE_PASSWORD=

# API Configuration
API_KEY=local-dev-key
SECRET_KEY=begin-masimba-secret-key-change-in-production-2025
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Backend Server Settings
PY_API_HOST=127.0.0.1
PY_API_PORT=8000
NODE_ENV=development

# CORS Settings
CORS_ORIGIN=http://localhost

# Multi-tenancy
TENANT_ID=1

# Logging
LOG_LEVEL=INFO
"""
    
    env_file = Path(__file__).parent / ".env"
    with open(env_file, 'w') as f:
        f.write(env_content)
    
    print(f"✅ Created .env file at {env_file}")

def check_database():
    """Check database connection and create tables if needed"""
    print("🔍 Checking database connection...")
    
    try:
        from common.database import engine, Base
        from common import models
        
        # Test connection
        with engine.connect() as conn:
            conn.execute("SELECT 1")
        
        # Create tables
        Base.metadata.create_all(bind=engine)
        print("✅ Database connection OK")
        return True
        
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        print("💡 Please ensure MySQL is running and database 'begin_masimba_farm' exists")
        return False

def start_backend():
    """Start the FastAPI backend server"""
    print("🚀 Starting FastAPI backend server...")
    
    try:
        # Change to backend directory
        os.chdir(backend_dir)
        
        # Start uvicorn server
        cmd = [
            sys.executable, "-m", "uvicorn",
            "app:app",
            "--host", "127.0.0.1",
            "--port", "8000",
            "--reload",
            "--log-level", "info"
        ]
        
        print(f"📍 Running command: {' '.join(cmd)}")
        print("🌐 Server will be available at: http://127.0.0.1:8000")
        print("📚 API docs available at: http://127.0.0.1:8000/docs")
        print("\n🔄 Starting server... (Press Ctrl+C to stop)")
        
        # Start the server
        subprocess.run(cmd, check=True)
        
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Failed to start server: {e}")
        return False
    
    return True

def main():
    """Main startup function"""
    print("🐍 Begin Masimba FarmOS Backend Startup")
    print("=" * 50)
    
    # Change to project root
    project_root = Path(__file__).parent
    os.chdir(project_root)
    
    # Check environment
    if not check_environment():
        print("❌ Environment check failed. Exiting.")
        sys.exit(1)
    
    # Check database
    if not check_database():
        print("❌ Database check failed. Exiting.")
        sys.exit(1)
    
    # Start backend
    if not start_backend():
        print("❌ Backend startup failed. Exiting.")
        sys.exit(1)

if __name__ == "__main__":
    main()
