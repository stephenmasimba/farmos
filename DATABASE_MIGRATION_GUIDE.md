# Database Migration & Password Reset Guide

**Date**: March 12, 2026  
**Purpose**: Guide for updating existing user accounts to meet new password requirements

---

## 🔄 MIGRATION OVERVIEW

The new security implementation requires:
1. All passwords to be hashed using bcrypt (done automatically on new users)
2. All passwords to meet complexity requirements (8+ chars, upper, lower, digit, special)
3. Environment variables to be properly configured

---

## 📋 PHASE 1: Environment Setup

### Step 1: Create .env File

```bash
cd begin_pyphp/backend
cp .env.example .env
```

### Step 2: Generate Strong Secrets

```python
# Generate JWT_SECRET
python -c "import secrets; print(secrets.token_hex(32))"
# Copy output to JWT_SECRET in .env

# Generate API_KEY
python -c "import secrets; print(secrets.token_urlsafe(32))"
# Copy output to API_KEY in .env

# Generate SECRET_KEY
python -c "import secrets; print(secrets.token_hex(32))"
# Copy output to SECRET_KEY in .env
```

### Step 3: Edit .env File

Edit `backend/.env` and update:

```env
NODE_ENV=development  # or production
JWT_SECRET=<your-generated-secret>
API_KEY=<your-generated-key>
SECRET_KEY=<your-generated-secret>
DATABASE_URL=mysql+pymysql://root:password@localhost:3306/begin_masimba_farm
CORS_ORIGIN=http://localhost
LOG_LEVEL=INFO
```

---

## 🔐 PHASE 2: Password Migration

### Option A: Manual Password Reset (Recommended)

For each existing user, reset their password:

```python
# reset_passwords.py
from backend.common.database import SessionLocal, engine, Base
from backend.common import models
from backend.common.security import hash_password

db = SessionLocal()

# Find all users
users = db.query(models.User).all()

for user in users:
    # Prompt for new password
    print(f"\nUser: {user.email}")
    new_password = input("Enter new password (min 8 chars, uppercase, lowercase, digit, special): ")
    
    # Hash with new bcrypt implementation
    user.hashed_password = hash_password(new_password)
    
print(f"Updated {len(users)} users")
db.commit()
```

Run it:
```bash
cd backend
python reset_passwords.py
```

### Option B: Bulk Reset to Temporary Password

```python
# bulk_reset.py
from backend.common.database import SessionLocal
from backend.common import models
from backend.common.security import hash_password

db = SessionLocal()

# Set temporary password for all users
temp_password = "TempPassword123!"
users = db.query(models.User).all()

for user in users:
    user.hashed_password = hash_password(temp_password)
    print(f"Reset {user.email}")

db.commit()
print(f"All {len(users)} users reset to temporary password")
print(f"Temporary password: {temp_password}")
print("Users should change password on first login")
```

### Option C: Create Demo Users with Strong Passwords

```python
# create_demo_users.py
from backend.common.database import SessionLocal
from backend.common import models
from backend.common.security import hash_password

db = SessionLocal()

demo_users = [
    {
        "name": "Admin User",
        "email": "admin@example.com",
        "password": "AdminPass123!"
    },
    {
        "name": "Manager User",
        "email": "manager@example.com",
        "password": "ManagerPass123!"
    },
    {
        "name": "Worker User",
        "email": "worker@example.com",
        "password": "WorkerPass123!"
    }
]

for user_data in demo_users:
    # Check if user exists
    existing = db.query(models.User).filter(
        models.User.email == user_data["email"]
    ).first()
    
    if existing:
        print(f"Updating: {user_data['email']}")
        existing.hashed_password = hash_password(user_data["password"])
    else:
        print(f"Creating: {user_data['email']}")
        new_user = models.User(
            name=user_data["name"],
            email=user_data["email"],
            hashed_password=hash_password(user_data["password"]),
            role="user"
        )
        db.add(new_user)

db.commit()
print("Demo users created/updated successfully")
```

Run it:
```bash
cd backend
python create_demo_users.py
```

---

## 🧪 PHASE 3: Testing

### Test 1: Verify Environment Setup

```bash
cd backend
python -c "
from common.config import settings
print(f'JWT Secret set: {bool(settings.SECRET_KEY)}')
print(f'API Key set: {bool(settings.API_KEY)}')
print(f'Database: {settings.DATABASE_URL}')
"
```

### Test 2: Verify Password Hashing

```bash
python -c "
from common.security import hash_password, verify_password
pwd = 'TestPass123!'
hashed = hash_password(pwd)
print(f'Password hashed: {bool(hashed)}')
print(f'Verification works: {verify_password(pwd, hashed)}')
"
```

### Test 3: Verify JWT Tokens

```bash
python -c "
from common.security import jwt_encode, jwt_decode
token = jwt_encode({'user_id': 1, 'email': 'test@example.com'})
decoded = jwt_decode(token)
print(f'Token generated: {bool(token)}')
print(f'Token decoded: {bool(decoded)}')
print(f'User ID matches: {decoded[\"user_id\"] == 1}')
"
```

### Test 4: Run Test Suite

```bash
pip install pytest pytest-cov
pytest tests/test_auth_security.py -v
```

Expected output:
```
test_login_success PASSED
test_register_success PASSED
test_password_validation_strong PASSED
test_jwt_decode_valid PASSED
[... more tests ...]
===================== XX passed in Xs =======================
```

---

## ⚙️ PHASE 4: Application Start

### Step 1: Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Create Database (if needed)

```bash
# Create the database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS begin_masimba_farm;"

# Create tables
python -c "
from common.database import Base, engine
Base.metadata.create_all(bind=engine)
print('Database tables created')
"
```

### Step 3: Start Backend

```bash
# Development
uvicorn app:app --reload

# Or production
uvicorn app:app --host 0.0.0.0 --port 8000
```

### Step 4: Test Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $(grep '^API_KEY=' .env | cut -d'=' -f2)" \
  -d '{
    "email": "admin@example.com",
    "password": "AdminPass123!"
  }'
```

Expected response:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

---

## 🚀 PHASE 5: Frontend Configuration

### For PHP Frontend

Update your frontend to send the API Key:

```php
// In your API client
$headers = array(
    'Content-Type: application/json',
    'X-API-Key: ' . getenv('API_KEY'),
    'Authorization: Bearer ' . $_SESSION['access_token'] ?? ''
);
```

### For React Frontend

```javascript
// api.js or similar
const API_KEY = process.env.REACT_APP_API_KEY;

const headers = {
    'Content-Type': 'application/json',
    'X-API-Key': API_KEY,
    'Authorization': `Bearer ${localStorage.getItem('token')}`
};
```

---

## 📊 MIGRATION CHECKLIST

- [ ] Created .env file from .env.example
- [ ] Generated strong JWT_SECRET
- [ ] Generated strong API_KEY
- [ ] Generated strong SECRET_KEY
- [ ] Updated DATABASE_URL in .env
- [ ] Set NODE_ENV appropriately
- [ ] Reset all user passwords to meet requirements
- [ ] Verified password hashing working
- [ ] Verified JWT tokens working
- [ ] Ran test suite - all passed
- [ ] Installed all dependencies
- [ ] Created database and tables
- [ ] Started backend successfully
- [ ] Tested login endpoint
- [ ] Updated frontend configuration
- [ ] Tested end-to-end login flow

---

## 🆘 TROUBLESHOOTING

### Issue: "JWT_SECRET must be set via environment variable"

**Cause**: .env file not created or JWT_SECRET not set

**Solution**:
```bash
cp .env.example .env
# Generate and add JWT_SECRET as described above
```

### Issue: "Database connection failed"

**Cause**: DATABASE_URL not set or MySQL not running

**Solution**:
```bash
# Verify MySQL is running
# Edit .env and ensure DATABASE_URL is correct
# Check credentials: mysql -u root -p -e "SHOW DATABASES;"
```

### Issue: "bcrypt not available"

**Cause**: Dependencies not installed

**Solution**:
```bash
pip install -r requirements.txt
```

### Issue: Login fails with "Invalid credentials"

**Cause**: Password doesn't match or user doesn't exist

**Solution**:
```bash
# Verify user exists in database
mysql -u root -p begin_masimba_farm -e "SELECT id, email FROM users;"

# Reset password if needed
python create_demo_users.py
```

### Issue: Rate limit exceeded on login

**Cause**: Too many login attempts from same IP

**Solution**:
```
Wait 60 seconds before next attempt
```

---

## 📝 MAINTENANCE

### Regular Tasks

- [ ] **Monthly**: Review logs for suspicious activity
- [ ] **Quarterly**: Update dependencies
- [ ] **Quarterly**: Review access logs
- [ ] **Annually**: Rotate API keys and secrets

### Monitoring

Monitor these logs for issues:
```bash
# Watch application logs
tail -f /var/log/farmos/farmos.log

# Check error logs
tail -f /var/log/farmos/farmos-error.log
```

---

## 📞 GETTING HELP

If you encounter issues:

1. Check the troubleshooting section above
2. Review logs in `/var/log/farmos/`
3. Run the verification tests
4. Check database connectivity
5. Verify .env configuration

---

**Migration Guard**: Always test in development before applying to production!
