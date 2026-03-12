"""
FarmOS Quick Launcher
Double-click to start FarmOS with auto-server
"""

import os
import sys
import subprocess
import webbrowser
import time
from pathlib import Path

def check_python_packages():
    """Check if required packages are installed"""
    required_packages = ['fastapi', 'uvicorn', 'sqlalchemy', 'pymysql', 'bcrypt', 'requests']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print(f"❌ Missing packages: {', '.join(missing_packages)}")
        print("💡 Install with: pip install " + " ".join(missing_packages))
        return False
    
    return True

def start_farmos():
    """Start FarmOS with auto-server"""
    print("🌟 FarmOS Quick Launcher")
    print("=" * 40)
    
    # Check Python packages
    if not check_python_packages():
        input("\nPress Enter to exit...")
        return
    
    # Change to backend directory
    backend_dir = Path(__file__).parent / "backend"
    os.chdir(backend_dir)
    
    print("🚀 Starting FarmOS server...")
    
    # Start server monitor in background
    try:
        monitor_process = subprocess.Popen(
            [sys.executable, "monitor_server.py"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
        )
        
        # Wait a moment for server to start
        time.sleep(3)
        
        # Open web browser
        print("🌐 Opening FarmOS in browser...")
        webbrowser.open("http://localhost:8081/farmos/")
        
        print("\n✅ FarmOS is running!")
        print("📍 Server: http://127.0.0.1:8000")
        print("🌐 Web Interface: http://localhost:8081/farmos/")
        print("📚 API Docs: http://127.0.0.1:8000/docs")
        
        print("\n🔑 Login Credentials:")
        print("📧 Admin: admin@masimba.farm / admin123")
        print("👨‍🌾 Manager: manager@masimba.farm / manager123")
        print("👷 Worker: worker@masimba.farm / worker123")
        
        print("\n💡 Close this window to stop FarmOS server")
        print("⏳ FarmOS is running... (Press Ctrl+C to stop)")
        
        # Keep running
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n👋 Stopping FarmOS...")
            monitor_process.terminate()
            print("✅ FarmOS stopped")
            
    except Exception as e:
        print(f"❌ Error starting FarmOS: {e}")
        input("\nPress Enter to exit...")

if __name__ == "__main__":
    start_farmos()
