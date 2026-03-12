"""
Setup FarmOS Auto-Start
Creates Windows startup shortcuts for automatic server launch
"""

import os
import sys
import winshell
from pathlib import Path

def create_startup_shortcut():
    """Create a shortcut in Windows startup folder"""
    try:
        # Get current directory
        current_dir = Path(__file__).parent
        batch_file = current_dir / "AUTO_START.bat"
        
        # Get startup folder
        startup_folder = Path(winshell.startup())
        
        # Create shortcut
        shortcut_path = startup_folder / "FarmOS.lnk"
        
        # Use PowerShell to create shortcut (more reliable)
        import subprocess
        
        powershell_script = f'''
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("{shortcut_path}")
$Shortcut.TargetPath = "{batch_file}"
$Shortcut.WorkingDirectory = "{current_dir}"
$Shortcut.Description = "FarmOS Auto-Start Server"
$Shortcut.Save()
'''
        
        result = subprocess.run(['powershell', '-Command', powershell_script], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Auto-start shortcut created!")
            print(f"📍 Location: {shortcut_path}")
            print("🔄 FarmOS will automatically start when Windows boots")
            return True
        else:
            print(f"❌ Failed to create shortcut: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error creating auto-start: {e}")
        return False

def remove_startup_shortcut():
    """Remove the startup shortcut"""
    try:
        startup_folder = Path(winshell.startup())
        shortcut_path = startup_folder / "FarmOS.lnk"
        
        if shortcut_path.exists():
            shortcut_path.unlink()
            print("✅ Auto-start shortcut removed!")
            return True
        else:
            print("ℹ️ No auto-start shortcut found")
            return True
            
    except Exception as e:
        print(f"❌ Error removing shortcut: {e}")
        return False

def main():
    print("🔧 FarmOS Auto-Start Setup")
    print("=" * 40)
    
    if len(sys.argv) > 1 and sys.argv[1] == "remove":
        remove_startup_shortcut()
    else:
        create_startup_shortcut()
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    main()
