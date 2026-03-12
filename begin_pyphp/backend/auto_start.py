"""
Auto-start Server for FarmOS
Automatically starts when the folder is accessed
"""

import os
import sys
import subprocess
import time
import requests
from threading import Thread
import signal
import atexit

# Server configuration
SERVER_HOST = "127.0.0.1"
SERVER_PORT = 8000
SERVER_SCRIPT = "simple_login_server.py"

class AutoStartServer:
    def __init__(self):
        self.server_process = None
        self.running = False
        
    def is_server_running(self):
        """Check if the server is already running"""
        try:
            response = requests.get(f"http://{SERVER_HOST}:{SERVER_PORT}/health", timeout=2)
            return response.status_code == 200
        except:
            return False
    
    def start_server(self):
        """Start the server if not already running"""
        if self.is_server_running():
            print("✅ FarmOS server is already running")
            return True
        
        if self.running:
            print("🔄 Server startup in progress...")
            return True
        
        try:
            print("🚀 Starting FarmOS server...")
            
            # Start the server process
            self.server_process = subprocess.Popen(
                [sys.executable, SERVER_SCRIPT],
                cwd=os.path.dirname(os.path.abspath(__file__)),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                creationflags=subprocess.CREATE_NEW_CONSOLE if os.name == 'nt' else 0
            )
            
            self.running = True
            
            # Wait for server to start
            for i in range(10):  # Wait up to 10 seconds
                time.sleep(1)
                if self.is_server_running():
                    print(f"✅ FarmOS server started successfully!")
                    print(f"📍 Server: http://{SERVER_HOST}:{SERVER_PORT}")
                    print(f"🔑 Login: http://localhost:8081/farmos/")
                    return True
            
            print("⚠️ Server started but health check failed")
            return True
            
        except Exception as e:
            print(f"❌ Failed to start server: {e}")
            self.running = False
            return False
    
    def stop_server(self):
        """Stop the server"""
        if self.server_process:
            try:
                self.server_process.terminate()
                self.server_process.wait(timeout=5)
                print("🛑 FarmOS server stopped")
            except:
                try:
                    self.server_process.kill()
                    print("🛑 FarmOS server force stopped")
                except:
                    pass
            finally:
                self.server_process = None
                self.running = False
    
    def auto_start(self):
        """Auto-start the server"""
        print("🌟 FarmOS Auto-Start System")
        print("=" * 40)
        
        # Start the server
        if self.start_server():
            print("🎉 FarmOS is ready!")
            print("\n📋 Quick Access:")
            print(f"🌐 Web Interface: http://localhost:8081/farmos/")
            print(f"🔧 API Server: http://{SERVER_HOST}:{SERVER_PORT}")
            print(f"📚 API Docs: http://{SERVER_HOST}:{SERVER_PORT}/docs")
            print("\n🔑 Login Credentials:")
            print("📧 Admin: admin@masimba.farm / admin123")
            print("👨‍🌾 Manager: manager@masimba.farm / manager123")
            print("👷 Worker: worker@masimba.farm / worker123")
            print("\n💡 Press Ctrl+C to stop the server")
            
            try:
                # Keep the script running
                while self.running and self.server_process and self.server_process.poll() is None:
                    time.sleep(1)
                    
                    # Check if server is still responding
                    if not self.is_server_running():
                        print("⚠️ Server stopped responding, restarting...")
                        self.stop_server()
                        self.start_server()
                        
            except KeyboardInterrupt:
                print("\n👋 Shutting down FarmOS server...")
                self.stop_server()
        else:
            print("❌ Failed to start FarmOS server")

# Global server instance
server = AutoStartServer()

# Register cleanup
atexit.register(server.stop_server)

# Handle Ctrl+C
def signal_handler(sig, frame):
    print("\n👋 Shutting down FarmOS server...")
    server.stop_server()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

if __name__ == "__main__":
    server.auto_start()
