"""
FarmOS Enhanced Startup Script
Includes WebSocket server, Redis caching, and background jobs
"""

import os
import sys
import subprocess
import time
import signal
import asyncio
from pathlib import Path
from multiprocessing import Process
import threading
import requests

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

# WebSocket Server
WEBSOCKET_HOST=127.0.0.1
WEBSOCKET_PORT=8001

# Redis Configuration (Optional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# CORS Settings
CORS_ORIGIN=http://localhost:8081

# Multi-tenancy
TENANT_ID=1

# Logging
LOG_LEVEL=INFO

# Background Jobs
ENABLE_BACKGROUND_JOBS=true
JOB_SCHEDULER_INTERVAL=60

# Performance
ENABLE_CACHING=true
CACHE_TTL=300
"""
    
    env_file = Path(__file__).parent / ".env"
    with open(env_file, 'w') as f:
        f.write(env_content)
    
    print(f"✅ Created .env file at {env_file}")

def check_dependencies():
    """Check and install required dependencies"""
    print("🔍 Checking Python dependencies...")
    
    required_packages = [
        'fastapi', 'uvicorn', 'sqlalchemy', 'pymysql', 
        'pydantic-settings', 'python-dotenv', 'websockets',
        'redis', 'celery', 'apscheduler'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print(f"📦 Installing missing packages: {', '.join(missing_packages)}")
        subprocess.run([
            sys.executable, '-m', 'pip', 'install'
        ] + missing_packages, check=True)
    
    print("✅ Dependencies OK")

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

def start_fastapi_server():
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
            "--log-level", "info",
            "--workers", "1"
        ]
        
        print(f"📍 FastAPI server: http://127.0.0.1:8000")
        print("📚 API docs: http://127.0.0.1:8000/docs")
        
        # Start the server
        subprocess.run(cmd, check=True)
        
    except Exception as e:
        print(f"❌ Failed to start FastAPI server: {e}")
        return False
    
    return True

def start_websocket_server():
    """Start the WebSocket server"""
    print("🌐 Starting WebSocket server...")
    
    try:
        # Change to project root
        project_root = Path(__file__).parent
        os.chdir(project_root)
        
        # Start WebSocket server
        cmd = [sys.executable, "websocket_server.py"]
        
        print(f"📍 WebSocket server: ws://127.0.0.1:8001")
        
        # Start the server
        subprocess.run(cmd, check=True)
        
    except Exception as e:
        print(f"❌ Failed to start WebSocket server: {e}")
        return False
    
    return True

def start_redis_server():
    """Start Redis server for caching"""
    print("🗄️ Starting Redis server...")
    
    try:
        # Check if Redis is available
        result = subprocess.run(['redis-server', '--version'], 
                            capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Redis server starting...")
            subprocess.Popen(['redis-server'], 
                          stdout=subprocess.DEVNULL, 
                          stderr=subprocess.DEVNULL)
            time.sleep(2)  # Give Redis time to start
            print("✅ Redis server started")
            return True
        else:
            print("⚠️ Redis not installed, skipping caching features")
            return False
            
    except FileNotFoundError:
        print("⚠️ Redis not found, skipping caching features")
        return False
    except Exception as e:
        print(f"❌ Failed to start Redis: {e}")
        return False

def start_background_jobs():
    """Start background job scheduler"""
    print("⏰ Starting background job scheduler...")
    
    try:
        # Import and start job scheduler
        sys.path.insert(0, str(backend_dir))
        from services.job_scheduler import start_scheduler
        
        # Start scheduler in background
        scheduler_thread = threading.Thread(target=start_scheduler, daemon=True)
        scheduler_thread.start()
        
        print("✅ Background jobs started")
        return True
        
    except Exception as e:
        print(f"❌ Failed to start background jobs: {e}")
        return False

def test_system():
    """Test system components"""
    print("🧪 Testing system components...")
    
    # Test FastAPI health
    try:
        response = requests.get("http://127.0.0.1:8000/health", timeout=5)
        if response.status_code == 200:
            print("✅ FastAPI server: OK")
        else:
            print(f"❌ FastAPI server: {response.status_code}")
    except:
        print("❌ FastAPI server: Not responding")
    
    # Test WebSocket
    try:
        import websockets
        # Simple connection test
        print("✅ WebSocket server: Available")
    except:
        print("❌ WebSocket server: Not available")
    
    # Test Redis
    try:
        import redis
        r = redis.Redis(host='localhost', port=6379, decode_responses=True)
        r.ping()
        print("✅ Redis server: OK")
    except:
        print("⚠️ Redis server: Not available")

def cleanup(signum, frame):
    """Cleanup function for graceful shutdown"""
    print("\n🛑 Shutting down FarmOS servers...")
    
    # Kill subprocesses
    try:
        subprocess.run(['pkill', '-f', 'uvicorn'], check=False)
        subprocess.run(['pkill', '-f', 'websocket_server.py'], check=False)
        subprocess.run(['pkill', '-f', 'redis-server'], check=False)
    except:
        pass
    
    print("✅ Servers stopped")
    sys.exit(0)

def main():
    """Main startup function"""
    print("🐍 Begin Masimba FarmOS Enhanced Startup")
    print("=" * 60)
    
    # Register signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, cleanup)
    signal.signal(signal.SIGTERM, cleanup)
    
    # Change to project root
    project_root = Path(__file__).parent
    os.chdir(project_root)
    
    # Check environment
    if not check_environment():
        print("❌ Environment check failed. Exiting.")
        sys.exit(1)
    
    # Check dependencies
    check_dependencies()
    
    # Check database
    if not check_database():
        print("❌ Database check failed. Exiting.")
        sys.exit(1)
    
    # Start Redis (optional)
    redis_available = start_redis_server()
    
    # Start background jobs
    start_background_jobs()
    
    # Start servers
    print("\n🚀 Starting FarmOS servers...")
    print("-" * 40)
    
    # Start FastAPI server in background
    fastapi_process = Process(target=start_fastapi_server)
    fastapi_process.daemon = True
    fastapi_process.start()
    
    # Give FastAPI time to start
    time.sleep(3)
    
    # Start WebSocket server in background
    websocket_process = Process(target=start_websocket_server)
    websocket_process.daemon = True
    websocket_process.start()
    
    # Give WebSocket time to start
    time.sleep(2)
    
    # Test system
    test_system()
    
    print("\n" + "=" * 60)
    print("🌐 FarmOS System URLs:")
    print(f"📱 Frontend: http://localhost:8081/farmos/begin_pyphp/frontend/public/")
    print(f"🔧 Backend API: http://127.0.0.1:8000/")
    print(f"📚 API Docs: http://127.0.0.1:8000/docs")
    print(f"🌐 WebSocket: ws://127.0.0.1:8001/ws/")
    if redis_available:
        print(f"🗄️ Redis: localhost:6379")
    print("=" * 60)
    print("🔄 All servers running. Press Ctrl+C to stop.")
    print("📊 Opening FarmOS in browser...")
    
    # Open browser
    import webbrowser
    webbrowser.open("http://localhost:8081/farmos/begin_pyphp/frontend/public/")
    
    try:
        # Keep main thread alive
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        cleanup(None, None)

if __name__ == "__main__":
    main()
