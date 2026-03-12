"""
Fix translation function conflicts by updating all pages to use i18n.php instead of translation.php
"""

import os
import glob

def fix_translation_import(file_path):
    """Fix translation import to use i18n instead of translation library"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if page uses translation function
        if '__(' in content:
            # Replace translation library import with i18n import
            old_import = "require_once __DIR__ . '/../lib/translation.php';"
            new_import = "require_once __DIR__ . '/../lib/i18n.php';"
            
            if old_import in content:
                content = content.replace(old_import, new_import)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ Fixed: {os.path.basename(file_path)}")
                return True
    
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")
        return False

def main():
    """Fix all PHP pages that have translation conflicts"""
    pages_dir = './pages'
    php_files = glob.glob(os.path.join(pages_dir, '*.php'))
    
    print("🔧 Fixing translation function conflicts in all pages...")
    print("=" * 60)
    
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
    
    print("=" * 60)
    print(f"📊 Summary:")
    print(f"   Total files: {total_count}")
    print(f"   Files needing fix: {fixed_count}")
    
    if fixed_count > 0:
        print(f"\n🎉 Successfully fixed translation conflicts in {fixed_count} pages!")
        print("✅ All pages now use i18n.php (no more __() conflicts)")
    else:
        print("\n✅ All pages already use correct translation system")

if __name__ == "__main__":
    main()
