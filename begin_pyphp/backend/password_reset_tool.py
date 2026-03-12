"""
FarmOS Password Reset Tool
Reset passwords for existing users in the database
"""

from sqlalchemy import create_engine, text
from common.database import SQLALCHEMY_DATABASE_URL
import bcrypt
import getpass

def reset_password():
    """Reset password for a user"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    print("🔑 FARMOS PASSWORD RESET TOOL")
    print("=" * 50)
    
    with engine.connect() as conn:
        # Show all users
        result = conn.execute(text('SELECT id, name, email, role FROM users ORDER BY id'))
        users = result.fetchall()
        
        if not users:
            print("❌ No users found in database!")
            return
        
        print("\n📋 AVAILABLE USERS:")
        for user in users:
            print(f"ID: {user[0]} | Name: {user[1]} | Email: {user[2]} | Role: {user[3]}")
        
        # Get user selection
        try:
            user_id = input("\nEnter User ID to reset password (or 'q' to quit): ")
            if user_id.lower() == 'q':
                return
            
            user_id = int(user_id)
            
            # Verify user exists
            user_result = conn.execute(text('SELECT name, email FROM users WHERE id = :id'), {'id': user_id})
            user = user_result.fetchone()
            
            if not user:
                print(f"❌ User with ID {user_id} not found!")
                return
            
            print(f"\n👤 Selected User: {user[0]} ({user[1]})")
            
            # Get new password
            new_password = getpass.getpass("Enter new password: ")
            confirm_password = getpass.getpass("Confirm new password: ")
            
            if new_password != confirm_password:
                print("❌ Passwords do not match!")
                return
            
            if len(new_password) < 6:
                print("❌ Password must be at least 6 characters!")
                return
            
            # Hash the password
            salt = bcrypt.gensalt()
            hashed_password = bcrypt.hashpw(new_password.encode('utf-8'), salt)
            
            # Update password in database
            update_result = conn.execute(
                text('UPDATE users SET hashed_password = :password WHERE id = :id'),
                {'password': hashed_password.decode('utf-8'), 'id': user_id}
            )
            conn.commit()
            
            if update_result.rowcount > 0:
                print(f"✅ Password successfully reset for {user[0]} ({user[1]})")
                print(f"🔑 New password: {new_password}")
                print(f"🌐 You can now login at: http://localhost:8081/farmos/")
            else:
                print("❌ Failed to update password!")
                
        except ValueError:
            print("❌ Invalid User ID!")
        except Exception as e:
            print(f"❌ Error: {e}")

def create_default_admin():
    """Create default admin user with known password"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    print("\n👑 CREATE DEFAULT ADMIN USER")
    print("=" * 50)
    
    with engine.connect() as conn:
        # Check if admin already exists
        result = conn.execute(text('SELECT COUNT(*) FROM users WHERE email = "admin@farmos.com"'))
        admin_exists = result.fetchone()[0] > 0
        
        if admin_exists:
            print("ℹ️  Admin user already exists!")
            choice = input("Do you want to reset the admin password? (y/n): ")
            if choice.lower() != 'y':
                return
            
            # Reset existing admin password
            new_password = "admin123"
            salt = bcrypt.gensalt()
            hashed_password = bcrypt.hashpw(new_password.encode('utf-8'), salt)
            
            conn.execute(
                text('UPDATE users SET hashed_password = :password WHERE email = "admin@farmos.com"'),
                {'password': hashed_password.decode('utf-8')}
            )
            conn.commit()
            
            print(f"✅ Admin password reset to: {new_password}")
            
        else:
            # Create new admin user
            salt = bcrypt.gensalt()
            hashed_password = bcrypt.hashpw("admin123".encode('utf-8'), salt)
            
            conn.execute(text('''
                INSERT INTO users (name, email, hashed_password, role, is_active, tenant_id)
                VALUES ("Administrator", "admin@farmos.com", :password, "admin", 1, "default")
            '''), {'password': hashed_password.decode('utf-8')})
            conn.commit()
            
            print("✅ Default admin user created!")
            print("📧 Email: admin@farmos.com")
            print("🔑 Password: admin123")
    
    print(f"🌐 Login at: http://localhost:8081/farmos/")

def list_all_users():
    """List all users with their details"""
    
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    
    print("\n📋 ALL USERS IN DATABASE")
    print("=" * 60)
    
    with engine.connect() as conn:
        result = conn.execute(text('''
            SELECT id, name, email, role, is_active, created_at 
            FROM users 
            ORDER BY id
        '''))
        users = result.fetchall()
        
        if not users:
            print("❌ No users found!")
            return
        
        print(f"{'ID':<5} {'Name':<20} {'Email':<25} {'Role':<10} {'Active':<8} {'Created':<20}")
        print("-" * 90)
        
        for user in users:
            active_status = "Yes" if user[4] else "No"
            created_date = str(user[5])[:19] if user[5] else "Unknown"
            print(f"{user[0]:<5} {user[1]:<20} {user[2]:<25} {user[3]:<10} {active_status:<8} {created_date:<20}")
        
        print(f"\nTotal users: {len(users)}")

def main():
    """Main menu"""
    
    while True:
        print("\n🔧 FARMOS PASSWORD MANAGEMENT")
        print("=" * 40)
        print("1. Reset user password")
        print("2. Create/reset default admin")
        print("3. List all users")
        print("4. Exit")
        
        choice = input("\nEnter your choice (1-4): ")
        
        if choice == '1':
            reset_password()
        elif choice == '2':
            create_default_admin()
        elif choice == '3':
            list_all_users()
        elif choice == '4':
            print("👋 Goodbye!")
            break
        else:
            print("❌ Invalid choice! Please try again.")

if __name__ == "__main__":
    main()
