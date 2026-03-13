# FarmOS Quick Start Guide

## 🚀 Quick Start Instructions

### 1. Configure Apache for Port 8081

Add the following to your Apache configuration:

**Option A: VirtualHost (Recommended)**
```apache
Listen 8081

<VirtualHost *:8081>
    ServerName localhost
    DocumentRoot "c:/wamp64/www/farmos"
    
    <Directory "c:/wamp64/www/farmos">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

**Option B: Simple Alias**
```apache
Alias "/farmos" "c:/wamp64/www/farmos"
<Directory "c:/wamp64/www/farmos">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

### 2. Start the System

**Method 1: Automated Test Script**
```bash
# Run the test script
test_system.bat
```

**Method 2: Manual Start**
```bash
# 1. Start WAMP server (Apache + MySQL)

# 2. Backend runs under Apache (WAMP) automatically:
#    http://localhost:8081/farmos/begin_pyphp/backend/

# 3. Access the application
http://localhost:8081/farmos/begin_pyphp/frontend/public/
```

### 3. System URLs

| Component | URL |
|-----------|------|
| **Main Application** | http://localhost:8081/farmos/begin_pyphp/frontend/public/ |
| **Dashboard** | http://localhost:8081/farmos/begin_pyphp/frontend/public/index.php?page=dashboard |
| **Login** | http://localhost:8081/farmos/begin_pyphp/frontend/public/index.php?page=login |
| **Backend Health** | http://localhost:8081/farmos/begin_pyphp/backend/health |

### 4. Default Login Credentials

```
Email: admin@farmos.local
Password: admin123
```

### 5. System Features

#### ✅ **Available Modules**
- **Dashboard**: Real-time KPIs and system overview
- **Financial Management**: Transactions, invoices, reports
- **Livestock Management**: Batches, breeding, health tracking
- **Inventory System**: Stock management, suppliers, alerts
- **Field Management**: Crop tracking, resource management
- **Equipment Management**: Maintenance, tracking
- **Task Management**: Assignment and tracking
- **User Management**: Roles, permissions
- **Reports**: Analytics and export capabilities
- **IoT Integration**: Sensor data and automation
- **Settings**: System configuration

#### 🌐 **Multi-language Support**
- English (en)
- Shona (sn)
- Ndebele (nd)

#### 📱 **Mobile Features**
- Responsive design
- Offline support
- PWA capabilities

### 6. Troubleshooting

#### **Backend Not Starting**
```bash
# Check PHP + Composer
php -v
composer -V

# Check database connection
mysql -u root -p -e "SHOW DATABASES;"
```

#### **Frontend Not Accessible**
```bash
# Check Apache configuration
httpd -t

# Restart Apache
# Through WAMP interface or:
net stop wampapache
net start wampapache
```

#### **Database Issues**
```bash
# Create database if not exists
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS begin_masimba_farm;"

# Check database tables
mysql -u root -p begin_masimba_farm -e "SHOW TABLES;"
```

### 7. Development Mode

For development, you can access the system at:
- **Development URL**: http://localhost/farmos/begin_pyphp/frontend/public/
- **Production URL**: http://localhost:8081/farmos/begin_pyphp/frontend/public/

### 8. API Testing

Test the backend API:
```bash
# Health check
curl http://127.0.0.1:8001/health

# API version
curl http://127.0.0.1:8001/api/version

# Dashboard data (with auth)
TOKEN=$(curl -s -X POST http://127.0.0.1:8001/api/auth/login -H "Content-Type: application/json" -d "{\"email\":\"admin@example.com\",\"password\":\"password123\"}" | php -r '$j=json_decode(stream_get_contents(STDIN), true); echo $j["access_token"] ?? "";')
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8001/api/dashboard/summary
```

---

## 📞 Support

For issues and support:
1. Check the troubleshooting section above
2. Review system logs in `logs/` directory
3. Check Apache error logs
4. Review the comprehensive documentation in `SYSTEM_FIXES.md`

---

*Last Updated: January 13, 2026*
