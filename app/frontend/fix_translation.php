"""
Fix translation function inclusion in all PHP pages
"""

import os
import glob

def fix_translation(file_path):
    """Add translation function inclusion to PHP file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if translation is already included
        if "require_once __DIR__ . '/../lang/en.php';" not in content:
            # Find the line after session check and before page_title
            lines = content.split('\n')
            new_lines = []
            
            for i, line in enumerate(lines):
                new_lines.append(line)
                
                # Add translation include after session check and before any usage
                if "if (empty(\$_SESSION['user']))" in line and i == 5:
                    new_lines.insert(i + 1, "// Include translation function")
                    new_lines.insert(i + 2, "require_once __DIR__ . '/../lang/en.php';")
                    break
            
            # Reconstruct content
            new_content = '\n'.join(new_lines)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"✅ Fixed: {os.path.basename(file_path)}")
            return True
    
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")
        return False

def main():
    """Fix all PHP pages that need translation"""
    pages_dir = './pages'
    php_files = glob.glob(os.path.join(pages_dir, '*.php'))
    
    print("🔧 Adding translation function to all pages...")
    print("=" * 50)
    
    fixed_count = 0
    total_count = 0
    
    for file_path in php_files:
        total_count += 1
        
        # Check if page uses translation function
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if '__(' in content:
            if fix_translation(file_path):
                fixed_count += 1
    
    print("=" * 50)
    print(f"📊 Summary:")
    print(f"   Total files: {total_count}")
    print(f"   Files needing translation: {fixed_count}")
    print(f"   Fixed files: {fixed_count}")
    
    if fixed_count > 0:
        print(f"\n🎉 Successfully added translation function to {fixed_count} pages!")
        print("✅ All pages now have __() function available")
    else:
        print("\n✅ All pages already have translation function")

if __name__ == "__main__":
    main()
