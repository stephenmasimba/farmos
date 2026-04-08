"""
Fix all pages to use translation library instead of direct lang file
"""

import os
import glob

def fix_translation_import(file_path):
    """Fix translation import to use translation library"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if page uses translation function
        if '__(' in content:
            # Replace direct lang import with translation library
            old_import = "require_once __DIR__ . '/../lang/en.php';"
            new_import = "require_once __DIR__ . '/../lib/translation.php';"
            
            if old_import in content:
                content = content.replace(old_import, new_import)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ Fixed: {os.path.basename(file_path)}")
                return True
            elif new_import not in content:
                # Add translation import if missing
                lines = content.split('\n')
                new_lines = []
                
                for i, line in enumerate(lines):
                    new_lines.append(line)
                    
                    # Add after session check
                    if 'if (empty($_SESSION[\'user\']))' in line and i < 10:
                        new_lines.insert(i + 1, "// Include translation function")
                        new_lines.insert(i + 2, "require_once __DIR__ . '/../lib/translation.php';")
                        break
                
                new_content = '\n'.join(new_lines)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                print(f"✅ Added: {os.path.basename(file_path)}")
                return True
    
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")
        return False

def main():
    """Fix all PHP pages that need translation"""
    pages_dir = './pages'
    php_files = glob.glob(os.path.join(pages_dir, '*.php'))
    
    print("🔧 Fixing translation imports in all pages...")
    print("=" * 50)
    
    fixed_count = 0
    total_count = 0
    
    for file_path in php_files:
        total_count += 1
        
        # Check if page uses translation function
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if '__(' in content:
            if fix_translation_import(file_path):
                fixed_count += 1
    
    print("=" * 50)
    print(f"📊 Summary:")
    print(f"   Total files: {total_count}")
    print(f"   Files needing translation: {fixed_count}")
    
    if fixed_count > 0:
        print(f"\n🎉 Successfully fixed translation imports in {fixed_count} pages!")
        print("✅ All pages now use translation library")
    else:
        print("\n✅ All pages already have correct translation imports")

if __name__ == "__main__":
    main()
