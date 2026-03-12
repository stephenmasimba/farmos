"""
FarmOS Server Monitor
Monitors and auto-starts the server when needed
"""

import os
import sys
import time
import subprocess
import requests
import threading
from pathlib import Path

class ServerMonitor:
    def __init__(self):
        self.server_process = None
        self.monitoring = True
        self.server_script = "simple_login_server.py"
        self.host = "127.0.0.1"
        self.port = 8000
        
    def is_server_running(self):
        """Check if server is responding"""
        try:
            response = requests.get(f"http://{self.host}:{self.port}/health", timeout=2)
            return response.status_code == 200
        except:
            return False
    
    def start_server(self):
        """Start the server"""
        if self.server_process and self.server_process.poll() is None:
            return True  # Already running
        
        try:
            print("🚀 Starting FarmOS server...")
            
            # Start server in background
            self.server_process = subprocess.Popen(
                [sys.executable, self.server_script],
                cwd=os.path.dirname(os.path.abspath(__file__)),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )
            
            # Wait for server to be ready
            for i in range(15):  # Wait up to 15 seconds
                time.sleep(1)
                if self.is_server_running():
                    print("✅ FarmOS server started successfully!")
                    return True
            
            print("⚠️ Server started but not responding")
            return True
            
        except Exception as e:
            print(f"❌ Failed to start server: {e}")
            return False
    
    def stop_server(self):
        """Stop the server"""
        if self.server_process:
            try:
                self.server_process.terminate()
                self.server_process.wait(timeout=5)
            except:
                try:
                    self.server_process.kill()
                except:
                    pass
            finally:
                self.server_process = None
    
    def monitor_loop(self):
        """Main monitoring loop"""
        print("👁️ FarmOS server monitor started")
        
        while self.monitoring:
            if not self.is_server_running():
                print("🔄 Server not running, starting...")
                self.start_server()
            
            time.sleep(5)  # Check every 5 seconds
    
    def start_monitoring(self):
        """Start the monitoring in background"""
        monitor_thread = threading.Thread(target=self.monitor_loop, daemon=True)
        monitor_thread.start()
        return monitor_thread
    
    def stop_monitoring(self):
        """Stop monitoring"""
        self.monitoring = False
        self.stop_server()

if __name__ == "__main__":
    monitor = ServerMonitor()
    
    try:
        # Start monitoring
        monitor_thread = monitor.start_monitoring()
        
        print("🌟 FarmOS Server Monitor Running")
        print("📍 Server: http://127.0.0.1:8000")
        print("🌐 Web Interface: http://localhost:8081/farmos/")
        print("\n💡 Press Ctrl+C to stop monitoring")
        
        # Keep script running
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\n👋 Stopping FarmOS server monitor...")
        monitor.stop_monitoring()
        print("✅ Monitor stopped")
