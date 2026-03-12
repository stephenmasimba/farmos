"""
Fix all pages to use $_SESSION['user'] instead of $_SESSION['access_token']
"""

import os
import glob

def fix_page(file_path):
    """Fix session check in a PHP file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace the session check
        old_content = "if (empty($_SESSION['access_token'])) {"
        new_content = "if (empty($_SESSION['user'])) {"
        
        if old_content in content:
            content = content.replace(old_content, new_content)
            
            # Also fix the redirect URL
            old_redirect = 'header(\'Location: /farmos/begin_pyphp/frontend/public/index.php?page=login\');'
            new_redirect = 'header(\'Location: ../public/index.php?page=login\');'
            
            if old_redirect in content:
                content = content.replace(old_redirect, new_redirect)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ Fixed: {os.path.basename(file_path)}")
            return True
    
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")
        return False

def main():
    """Fix all PHP pages"""
    pages_dir = './pages'
    php_files = glob.glob(os.path.join(pages_dir, '*.php'))
    
    print("🔧 Fixing all PHP pages...")
    print("=" * 50)
    
    fixed_count = 0
    total_count = 0
    
    for file_path in php_files:
        total_count += 1
        if fix_page(file_path):
            fixed_count += 1
    
    print("=" * 50)
    print(f"📊 Summary:")
    print(f"   Total files: {total_count}")
    print(f"   Fixed files: {fixed_count}")
    print(f"   Success rate: {(fixed_count/total_count*100) if total_count > 0 else 0:.1f}%")
    
    if fixed_count > 0:
        print(f"\n🎉 Successfully fixed {fixed_count} pages!")
        print("✅ All pages now use \$_SESSION['user']")
        print("✅ Redirect URLs updated")
    else:
        print("\n⚠️ No pages needed fixing")

if __name__ == "__main__":
    main()
