# API and User Docs Consolidated

Generated: 2026-04-08 15:57:53

---

## Source: C:\wamp64\www\farmos\app\docs\api_docs.md

# Begin Masimba - API Documentation

## Overview
Begin Masimba exposes a RESTful API built in PHP. This API powers the frontend and can be used for third-party integrations.

## Base URL
- WAMP/XAMPP: `http://localhost/farmos/app/backend`
- PHP built-in server (optional): `http://127.0.0.1:8001`

## Authentication
All API endpoints (except login/registration) require authentication.

### Headers
Include the following headers in your requests:
- `Authorization`: `Bearer <your_access_token>`
- `X-Tenant-ID`: `1` (or your specific tenant ID)

### Obtaining a Token
1. Send a POST request to `/api/auth/login` with your email and password.
2. The response will contain an `access_token`.

## Key Endpoints

### Users
- `GET /api/users/me`: Get current user profile.
- `POST /api/users`: Create a new user.

### Livestock
- `GET /api/livestock`: List all livestock.
- `POST /api/livestock`: Add new livestock.

### Fields
- `GET /api/fields`: List all fields.
- `POST /api/fields`: Add a new field.

### Financial
- `GET /api/financial/transactions`: List transactions.
- `POST /api/financial/transactions`: Add a transaction.

### IoT
- `POST /api/iot/ingest`: Ingest sensor data.

## Error Handling
The API returns standard HTTP status codes:
- `200 OK`: Success.
- `201 Created`: Resource created successfully.
- `400 Bad Request`: Invalid input.
- `401 Unauthorized`: Missing or invalid authentication.
- `403 Forbidden`: Insufficient permissions.
- `404 Not Found`: Resource not found.
- `500 Internal Server Error`: Server-side issue.


---

## Source: C:\wamp64\www\farmos\app\docs\deployment_guide.md

# Begin Masimba - Deployment Guide

## Production Deployment

### Prerequisites
- Linux Server (Ubuntu 20.04+ recommended)
- PHP 8.0+
- Web Server (Nginx or Apache)
- Database (MySQL recommended for production)

### Backend Deployment

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-repo/app.git
   cd app/backend
   ```

2. **Install Dependencies**:
   ```bash
   composer install --no-dev --optimize-autoloader
   ```

3. **Configure Environment**:
   Create a `.env` file with production settings:
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://your-domain.com
   DATABASE_HOST=localhost
   DATABASE_PORT=3306
   DATABASE_NAME=begin_masimba_farm
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   JWT_SECRET=your-production-secret-key
   ```

4. **Run with PHP-FPM (Recommended)**:
   ```bash
   php-fpm8.0 -t
   ```

5. **Serve the Backend**:
   Point your web server document root to `backend/public/`.

### Frontend Deployment

1. **Configure Web Server (Nginx)**:
   Create `/etc/nginx/sites-available/farmos`:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /path/to/app/frontend/public;
       index index.php;

       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }

       location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
       }
   }
   ```

2. **Enable Site**:
   ```bash
   ln -s /etc/nginx/sites-available/farmos /etc/nginx/sites-enabled/
   nginx -t
   systemctl restart nginx
   ```

### Database Migration
Ensure your production database is initialized with the schema files in `database/`.

```bash
mysql -u user -p dbname < database/schema.sql
# Apply other schema files as needed
```

### Security
- Use HTTPS (Let's Encrypt).
- Set secure passwords and API keys.
- Restrict database access.
- Regularly update dependencies.


---

## Source: C:\wamp64\www\farmos\app\docs\developer_guide.md

# Begin Masimba - Developer Guide

## Contributing
We welcome contributions to Begin Masimba! Please follow these guidelines to ensure code quality and consistency.

## Project Structure
- `backend/`: PHP backend API.
  - `public/`: Web root (index.php).
  - `src/`: Controllers, models, and core classes.
  - `tests/`: PHPUnit test suite.
- `frontend/`: PHP frontend application.
  - `pages/`: UI pages.
  - `components/`: Reusable UI components.
  - `lib/`: Helper libraries (API client, i18n).
  - `public/`: Static assets and entry point.
- `database/`: SQL schema files.
- `docs/`: Documentation.

## Setup Development Environment

1. **Prerequisites**:
   - PHP 8.0+
   - MySQL/MariaDB
   - Composer

2. **Backend Setup**:
   ```bash
   cd backend
   composer install
   composer run serve
   ```

3. **Frontend Setup**:
   Serve the `frontend/public` directory using a web server (e.g., Apache, Nginx, or PHP built-in server).
   ```bash
   cd frontend/public
   php -S localhost:8080
   ```

## Coding Standards

### PHP (Frontend)
- Follow PSR-12 coding standard.
- Use the `call_api` helper for backend requests.
- Ensure HTML is semantic and accessible.
- Use Tailwind CSS for styling.

## Workflow
1. Create a new branch for your feature or bugfix.
2. Implement your changes.
3. Run tests (`composer run test` for backend).
4. Submit a Pull Request (PR) with a clear description of your changes.

## Testing
- **Backend Tests**: `cd backend && composer run test`

## Deployment
See `docs/deployment_guide.md` for deployment instructions.


---

## Source: C:\wamp64\www\farmos\app\docs\troubleshooting.md

# Begin Masimba - Troubleshooting Guide

## Common Issues

### 1. Login Failed
**Symptom**: "Invalid credentials" error on login.
**Solution**:
- Check if the database is initialized.
- Ensure the user exists in the `users` table.
- Verify the password hash matches (passwords are hashed with bcrypt).
- Check backend logs for errors.

### 2. API Connection Refused
**Symptom**: Frontend shows "Failed to fetch" or connection errors.
**Solution**:
- Ensure your web server is serving the backend (`app/backend/`).
- If using the PHP built-in server, ensure it's running on port 8001.
- Verify `API_BASE_URL` (or `PHP_API_BASE_URL`) matches the backend URL.
- Check CORS settings in `backend/config/env.php`.

### 3. Missing Data
**Symptom**: Tables or lists are empty.
**Solution**:
- Check database connection string in `.env`.
- Inspect browser network tab for API errors (404, 500).

### 4. 401 Unauthorized / 403 Forbidden
**Symptom**: API requests fail with auth errors.
**Solution**:
- Ensure you are logged in and the token is valid.
- Check `Authorization` header format: `Bearer <token>`.
- Verify `Authorization` and `X-Tenant-ID` headers are present.
- Check user role permissions.

## Logs
- **Backend Logs**: Check standard output or configured log files.
- **Frontend Logs**: Check browser console (F12 > Console).
- **Web Server Logs**: Check `/var/log/nginx/error.log` or similar.

## Support
For further assistance, please contact the support team or open an issue on the repository.


---

## Source: C:\wamp64\www\farmos\app\docs\user_manual.md

# Begin Masimba - User Manual

## Introduction
Begin Masimba is a comprehensive Farm Management System designed to digitize and optimize farm operations. It covers everything from livestock and crop management to financial tracking and compliance.

## Getting Started

### Login
1. Navigate to the login page.
2. Enter your credentials (email and password).
3. Click "Sign In".

### Dashboard
The dashboard provides an overview of your farm's performance, including:
- Key metrics (Revenue, Expenses, Profit).
- Recent alerts and notifications.
- Quick access to modules.

## Modules

### Livestock Management
- **View Livestock**: See a list of all animals.
- **Add Animal**: Register new livestock with tag IDs, breed, and birth date.
- **Log Events**: Record vaccinations, treatments, and movements.

### Crop & Field Management
- **Fields**: Map and manage your fields.
- **Crop Cycles**: Track planting, growth, and harvest cycles.
- **Inputs**: Record fertilizer and pesticide usage.

### Financial Management
- **Transactions**: Log income and expenses.
- **Budgets**: Set and track budgets for different categories.
- **Invoices**: Generate invoices for sales.

### Inventory
- **Stock**: Track feed, seeds, chemicals, and equipment.
- **Suppliers**: Manage supplier contact information.

### Waste & Nutrient Cycling
- **Biogas**: Log feedstock input and gas output.
- **Compost**: Manage compost piles and turnings.
- **Manure**: Track manure collection and application.

### Feed Management
- **Ingredients**: Manage feed ingredients and their nutritional content.
- **Formulation**: Use the Pearson Square calculator to formulate feed.
- **Milling**: Log feed milling batches.

### Marketplace
- **Listings**: Browse available products.
- **Orders**: Place and track orders.

### IoT Monitoring
- **Devices**: View connected sensors (soil moisture, temperature).
- **Data**: Analyze real-time data from your farm.

### Compliance
- **Certifications**: Track compliance with standards (GlobalGAP, Organic).
- **Audits**: Prepare for and record audit results.

### Settings
- **Profile**: Update your user profile.
- **System**: Configure application settings (if admin).

## Mobile App
Begin Masimba is a Progressive Web App (PWA). You can install it on your mobile device for offline access and field data entry.


---

## Source: C:\wamp64\www\farmos\app\frontend\ROUTING_SETUP.md

# FarmOS Frontend Routing Setup
## 🚀 Complete URL Routing Configuration

---

## 📁 **Directory Structure**

```
c:/wamp64/www/farmos/
├── .htaccess                    # Root redirect to frontend
├── app/
│   ├── .htaccess               # Main routing handler
│   ├── frontend/
│   │   ├── .htaccess           # Frontend redirect to public
│   │   └── public/
│   │       ├── .htaccess       # Clean URL routing
│   │       └── index.php       # Main router
│   └── backend/                # API endpoints
```

---

## 🌐 **URL Routing Configuration**

### **1. Root Level (/farmos/)**
**File**: `c:/wamp64/www/farmos/.htaccess`
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /farmos/
    
    # Redirect root /farmos/ to the frontend
    RewriteRule ^$ app/frontend/public/ [L]
    
    # Redirect /farmos/anything to frontend
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.+)$ app/frontend/public/$1 [L]
</IfModule>
```

### **2. Project Level (/farmos/app/)**
**File**: `c:/wamp64/www/farmos/app/.htaccess`
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /farmos/app/
    
    # Redirect to frontend by default
    RewriteRule ^$ frontend/public/ [L]
    
    # Handle API routes to backend
    RewriteRule ^api/(.+)$ backend/api.php?endpoint=$1 [L,QSA]
    
    # Handle admin routes to backend
    RewriteRule ^admin/(.+)$ backend/admin.php?page=$1 [L,QSA]
    
    # Redirect everything else to frontend
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.+)$ frontend/public/$1 [L]
</IfModule>
```

### **3. Frontend Level (/farmos/app/frontend/)**
**File**: `c:/wamp64/www/farmos/app/frontend/.htaccess`
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /farmos/app/frontend/
    
    # Redirect to public folder
    RewriteRule ^$ public/ [L]
    RewriteRule ^(.+)$ public/$1 [L]
</IfModule>
```

### **4. Public Level (/farmos/app/frontend/public/)**
**File**: `c:/wamp64/www/farmos/app/frontend/public/.htaccess`
```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /farmos/app/frontend/public/
    
    # Handle the main index route
    RewriteRule ^index\.php$ - [L]
    
    # Route all requests to index.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /farmos/app/frontend/public/index.php [L]
    
    # Handle clean URLs for pages
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^([a-zA-Z0-9_-]+)$ index.php?page=$1 [L,QSA]
    
    # Handle subdirectory URLs
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)$ index.php?page=$1&subpage=$2 [L,QSA]
</IfModule>
```

---

## 🎯 **URL Mapping Examples**

### **Basic Navigation**
| URL | Routes To | Description |
|-----|-----------|-------------|
| `http://localhost:8081/farmos/` | Dashboard | Main entry point |
| `http://localhost:8081/farmos/login` | Login Page | User authentication |
| `http://localhost:8081/farmos/dashboard` | Dashboard | Main dashboard |
| `http://localhost:8081/farmos/livestock` | Livestock Management | Livestock module |

### **Advanced Features**
| URL | Routes To | Description |
|-----|-----------|-------------|
| `http://localhost:8081/farmos/biogas` | Biogas System | Biogas management |
| `http://localhost:8081/farmos/predictive_maintenance` | Predictive Maintenance | AI-powered maintenance |
| `http://localhost:8081/farmos/feed_formulation` | Feed Formulation | Advanced feed system |
| `http://localhost:8081/farmos/financial_analytics` | Financial Analytics | Advanced financial tools |

### **API Routes**
| URL | Routes To | Description |
|-----|-----------|-------------|
| `http://localhost:8081/farmos/api/users` | Backend API | User management |
| `http://localhost:8081/farmos/api/livestock` | Backend API | Livestock data |
| `http://localhost:8081/farmos/api/inventory` | Backend API | Inventory management |

---

## 🔧 **Router Logic (index.php)**

### **Authentication Check**
```php
// If user is not logged in and not on login page, redirect to login
if (!isset($_SESSION['user_id']) && $page !== 'login') {
    header('Location: /farmos/app/frontend/public/index.php?page=login');
    exit;
}
```

### **Page Routing**
The router supports **40+ different pages** including:
- **Core**: dashboard, livestock, inventory, financial
- **Advanced**: biogas, predictive_maintenance, feed_formulation
- **Management**: users, settings, analytics, reports
- **IoT**: iot, weather, field_mode
- **Enterprise**: sales_crm, production_management, energy_management

---

## 🚀 **How It Works**

### **1. User Access Flow**
1. User visits `http://localhost:8081/farmos/`
2. Root `.htaccess` redirects to `app/frontend/public/`
3. Frontend `.htaccess` routes to `public/` folder
4. Public `.htaccess` handles clean URLs
5. `index.php` routes to appropriate page
6. Authentication check redirects to login if needed

### **2. Clean URL Support**
- `http://localhost:8081/farmos/livestock` → `index.php?page=livestock`
- `http://localhost:8081/farmos/biogas` → `index.php?page=biogas`
- `http://localhost:8081/farmos/users/edit/123` → `index.php?page=users&subpage=edit&id=123`

### **3. API Integration**
- `http://localhost:8081/farmos/api/livestock` → `backend/api.php?endpoint=livestock`
- `http://localhost:8081/farmos/admin/users` → `backend/admin.php?page=users`

---

## ✅ **Setup Verification**

### **Files Created/Updated:**
- ✅ `c:/wamp64/www/farmos/.htaccess` - Root redirect
- ✅ `c:/wamp64/www/farmos/app/.htaccess` - Main routing
- ✅ `c:/wamp64/www/farmos/app/frontend/.htaccess` - Frontend redirect
- ✅ `c:/wamp64/www/farmos/app/frontend/public/.htaccess` - Clean URLs
- ✅ `c:/wamp64/www/farmos/app/frontend/public/index.php` - Router logic

### **Expected Behavior:**
1. **Root URL**: `http://localhost:8081/farmos/` → Dashboard (or login if not authenticated)
2. **Any Page**: `http://localhost:8081/farmos/[pagename]` → Corresponding page
3. **Clean URLs**: No `.php` extension needed
4. **API Routes**: Properly routed to backend
5. **404 Handling**: Graceful error pages for missing pages

---

## 🎯 **Testing the Setup**

### **Test URLs to Try:**
1. `http://localhost:8081/farmos/` - Should show dashboard/login
2. `http://localhost:8081/farmos/login` - Should show login page
3. `http://localhost:8081/farmos/dashboard` - Should show dashboard
4. `http://localhost:8081/farmos/livestock` - Should show livestock management
5. `http://localhost:8081/farmos/biogas` - Should show biogas system

### **Troubleshooting:**
- **404 Errors**: Check Apache mod_rewrite is enabled
- **Redirect Loops**: Verify .htaccess file permissions
- **Access Denied**: Ensure directory permissions are correct
- **Blank Pages**: Check PHP error logs

---

## 🎉 **ROUTING SETUP COMPLETE!**

### **What's Been Accomplished:**
- ✅ **Root URL routing** from `/farmos/` to index
- ✅ **Clean URL support** without `.php` extensions
- ✅ **Multi-level routing** with proper redirects
- ✅ **API route handling** for backend integration
- ✅ **Authentication integration** with login redirects
- ✅ **404 error handling** for missing pages

### **Ready for Use:**
The FarmOS frontend now has a complete, professional URL routing system that handles all navigation cleanly and efficiently!

**🚀 All URLs within the project now route correctly to the index!**


---

## Source: C:\wamp64\www\farmos\API_DOCUMENTATION.md

# FarmOS API Documentation

**Version**: 1.0.0  
**Last Updated**: March 12, 2026  
**Base URL**: `http://localhost/farmos/app/backend/api` (WAMP) | `http://127.0.0.1:8001/api` (Built-in) | `https://api.yourdomain.com/api` (Production)

---

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [Authentication](#authentication)
3. [API Overview](#api-overview)
4. [Request/Response Format](#requestresponse-format)
5. [Error Handling](#error-handling)
6. [Authentication Endpoints](#authentication-endpoints)
7. [Core Modules](#core-modules)
8. [Rate Limiting](#rate-limiting)
9. [Best Practices](#best-practices)
10. [Examples](#examples)

---

## Introduction

The FarmOS API is a RESTful API that provides complete access to farm management functionality including livestock management, inventory tracking, financial operations, and IoT integration.

### Key Features
- ✅ JWT-based authentication
- ✅ Rate limiting for abuse prevention
- ✅ Comprehensive error handling
- ✅ Extensive input validation
- ✅ Structured logging and monitoring
- ✅ Multi-tenant support

### Requirements
- API Version: 1.0.0
- HTTP Method: REST (GET, POST, PUT, DELETE, PATCH)
- Content-Type: application/json
- Authentication: Bearer Token or API Key

---

## Authentication

### Overview

FarmOS supports two authentication methods:

1. **JWT Token** (User Authentication) - For user sessions
2. **API Key** (Application Authentication) - For third-party integrations

### JWT Token Authentication

#### How It Works

1. User logs in with email/password
2. Server returns JWT access token (expires in 1 hour)
3. Client includes token in `Authorization` header
4. Token can be refreshed using `/refresh-token` endpoint

#### Headers

```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

#### Token Structure

JWT tokens contain:
```json
{
  "sub": "1",
  "id": 1,
  "email": "user@example.com",
  "role": "admin",
  "name": "John Doe",
  "iat": 1678604445,
  "exp": 1678608045
}
```

### Request Headers (Recommended)

```
Authorization: Bearer <jwt_token>
Content-Type: application/json
X-Tenant-ID: default
```

---

## API Overview

### API Structure

```
/api/
├── /auth              # Authentication (login, register, profile)
├── /livestock        # Livestock management
├── /inventory        # Inventory tracking
├── /dashboard        # Dashboards and analytics
├── /fields           # Field management
├── /tasks            # Task management
├── /financial        # Financial operations
├── /iot              # IoT sensor data
├── /weather          # Weather data
├── /reports          # Report generation
├── /notifications    # Notifications
└── [20+ more modules]
```

### HTTP Methods

| Method | Purpose |
|--------|---------|
| GET | Retrieve data |
| POST | Create new resource |
| PUT | Update entire resource |
| PATCH | Update partial resource |
| DELETE | Remove resource |

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (auth failed) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 409 | Conflict |
| 429 | Too Many Requests (rate limited) |
| 500 | Internal Server Error |

---

## Request/Response Format

### Request Format

All requests must be JSON:

```json
{
  "field1": "value1",
  "field2": "value2",
  "field3": {
    "nested_field": "nested_value"
  }
}
```

### Response Format (Success)

```json
{
  "id": 123,
  "name": "Example Item",
  "created_at": "2026-03-12T10:30:45Z",
  "updated_at": "2026-03-12T10:30:45Z",
  "data": {...}
}
```

### Response Format (List)

```json
{
  "items": [
    {
      "id": 1,
      "name": "Item 1"
    },
    {
      "id": 2,
      "name": "Item 2"
    }
  ],
  "total": 2,
  "page": 1,
  "page_size": 10
}
```

### Response Format (Error)

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Input validation failed",
    "http_status": 400,
    "timestamp": "2026-03-12T10:30:45Z",
    "request_id": "req-12345",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

---

## Error Handling

### Error Codes

The API uses standardized error codes for consistency:

```
UNAUTHORIZED              # 401 - Authentication failed
INVALID_CREDENTIALS       # 401 - Wrong password/username
TOKEN_EXPIRED             # 401 - JWT token expired
FORBIDDEN                 # 403 - Insufficient permissions
VALIDATION_ERROR          # 400 - Input validation failed
INVALID_INPUT             # 400 - Malformed input
NOT_FOUND                 # 404 - Resource not found
ALREADY_EXISTS            # 409 - Resource already exists
CONFLICT                  # 409 - Business logic conflict
RATE_LIMIT_EXCEEDED       # 429 - Too many requests
INTERNAL_SERVER_ERROR     # 500 - Server error
```

### Error Response Example

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Input validation failed",
    "http_status": 400,
    "timestamp": "2026-03-12T10:30:45Z",
    "request_id": "req-abc123def456",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "code": "INVALID_FORMAT"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters",
        "code": "TOO_SHORT"
      }
    ]
  }
}
```

### Handling Errors in Code

```javascript
// JavaScript/Node.js example
try {
  const response = await fetch('/api/livestock', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    const error = await response.json();
    console.error(`Error [${error.error.code}]: ${error.error.message}`);
    console.error('Details:', error.error.details);
  }
} catch (error) {
  console.error('Network error:', error);
}
```

---

## Authentication Endpoints

### POST /api/auth/login

**Description**: Authenticate user and get JWT token

**Rate Limit**: 5 requests per minute

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "role": "admin"
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  }
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "AdminPass123!"
  }'
```

---

### POST /api/auth/register

**Description**: Register a new user account

**Request**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "confirm_password": "SecurePass123!",
  "phone": "+1234567890"
}
```

**Password Requirements**:
- Minimum 8 characters
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one digit (0-9)
- At least one special character (!@#$%^&*)

**Response** (200 OK):
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "user": {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "worker"
  }
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!",
    "phone": "+1234567890"
  }'
```

---

### GET /api/auth/me

**Description**: Get current user profile

**Authentication**: Required (Bearer Token)

**Response** (200 OK):
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "user@example.com",
  "role": "admin",
  "created_at": "2026-03-12T10:30:45Z"
}
```

**Example**:
```bash
curl -X GET http://127.0.0.1:8001/api/auth/me \
  -H "Authorization: Bearer eyJ0eXAi..."
```

---

### POST /api/auth/refresh-token

**Description**: Refresh JWT access token

**Authentication**: Required (Bearer Token)

**Response** (200 OK):
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

**Example**:
```bash
curl -X POST http://127.0.0.1:8001/api/auth/refresh-token \
  -H "Authorization: Bearer eyJ0eXAi..."
```

---

## Core Modules

### Livestock Module (`/api/livestock`)

**Description**: Manage animal batches and livestock data

#### GET /api/livestock

List all livestock batches

**Query Parameters**:
- `page` (int, default=1): Page number for pagination
- `page_size` (int, default=10): Items per page
- `sort_by` (string): Field to sort by
- `search` (string): Search query

**Response**:
```json
{
  "items": [
    {
      "id": 1,
      "batch_name": "Batch A",
      "animal_type": "cattle",
      "count": 50,
      "acquisition_date": "2026-01-15",
      "status": "active"
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 10
}
```

**Example**:
```bash
curl -X GET "http://127.0.0.1:8001/api/livestock?page=1&page_size=10" \
  -H "Authorization: Bearer eyJ0eXAi..."
```

#### POST /api/livestock

Create a new livestock batch

**Request**:
```json
{
  "batch_name": "Spring Batch 2026",
  "animal_type": "cattle",
  "count": 50,
  "acquisition_date": "2026-03-12",
  "supplier": "Farm Supplier Inc",
  "notes": "Healthy stock from certified supplier"
}
```

**Response** (201 Created):
```json
{
  "id": 2,
  "batch_name": "Spring Batch 2026",
  "animal_type": "cattle",
  "count": 50,
  "acquisition_date": "2026-03-12",
  "status": "active",
  "created_at": "2026-03-12T10:30:45Z"
}
```

#### GET /api/livestock/{id}

Get details of a specific livestock batch

**Response**:
```json
{
  "id": 1,
  "batch_name": "Batch A",
  "animal_type": "cattle",
  "count": 50,
  "acquisition_date": "2026-01-15",
  "status": "active",
  "location": "Field 1",
  "notes": "Healthy stock",
  "created_at": "2026-01-15T10:30:45Z",
  "updated_at": "2026-03-12T14:20:30Z"
}
```

#### PUT /api/livestock/{id}

Update a livestock batch

**Request**:
```json
{
  "batch_name": "Batch A - Updated",
  "count": 48,
  "status": "active"
}
```

#### DELETE /api/livestock/{id}

Delete a livestock batch

**Response** (204 No Content)

---

### Inventory Module (`/api/inventory`)

**Description**: Track inventory items and stock levels

#### GET /api/inventory

List all inventory items

**Response**:
```json
{
  "items": [
    {
      "id": 1,
      "item_name": "Animal Feed",
      "item_type": "feed",
      "quantity": 100,
      "unit": "kg",
      "min_quantity": 20,
      "max_quantity": 500,
      "reorder_point": 50,
      "last_updated": "2026-03-12T14:20:30Z"
    }
  ],
  "total": 1
}
```

#### POST /api/inventory

Create a new inventory item

**Request**:
```json
{
  "item_name": "Premium Feed Mix",
  "item_type": "feed",
  "quantity": 200,
  "unit": "kg",
  "min_quantity": 25,
  "max_quantity": 500,
  "reorder_point": 75,
  "supplier_id": 1
}
```

#### GET /api/inventory/{id}

Get inventory item details

#### PUT /api/inventory/{id}

Update inventory item

#### DELETE /api/inventory/{id}

Delete inventory item

---

### Dashboard Module (`/api/dashboard`)

**Description**: Get dashboard metrics and alerts

#### GET /api/dashboard/alerts

Get current system alerts

**Response**:
```json
{
  "alerts": [
    {
      "id": 1,
      "type": "warning",
      "message": "Low feed inventory",
      "severity": "medium",
      "created_at": "2026-03-12T14:20:30Z"
    }
  ],
  "total": 1
}
```

#### GET /api/dashboard/metrics

Get key metrics and KPIs

**Response**:
```json
{
  "total_livestock": 500,
  "active_batches": 5,
  "total_inventory_value": 45000,
  "monthly_revenue": 125000,
  "pending_tasks": 12
}
```

---

### Financial Module (`/api/financial`)

**Description**: Manage financial operations

#### GET /api/financial/transactions

List financial transactions

**Response**:
```json
{
  "items": [
    {
      "id": 1,
      "type": "sale",
      "amount": 5000,
      "description": "Livestock sale",
      "date": "2026-03-10",
      "status": "completed"
    }
  ],
  "total": 1
}
```

#### POST /api/financial/transactions

Create a new transaction

**Request**:
```json
{
  "type": "sale",
  "amount": 7500,
  "description": "Livestock sale - Batch A",
  "buyer": "Market Buyer Inc",
  "date": "2026-03-12"
}
```

---

### IoT Module (`/api/iot`)

**Description**: IoT sensor data management

#### GET /api/iot/sensors

List all connected sensors

**Response**:
```json
{
  "items": [
    {
      "id": 1,
      "name": "Barn Temperature Sensor",
      "type": "temperature",
      "location": "Barn 1",
      "status": "active",
      "last_reading": 28.5,
      "last_updated": "2026-03-12T14:20:30Z"
    }
  ]
}
```

#### GET /api/iot/readings

Get sensor readings

**Query Parameters**:
- `sensor_id` (int): Filter by sensor
- `start_date` (string): Start date (ISO 8601)
- `end_date` (string): End date (ISO 8601)

**Response**:
```json
{
  "readings": [
    {
      "id": 1,
      "sensor_id": 1,
      "value": 28.5,
      "unit": "°C",
      "timestamp": "2026-03-12T14:20:30Z"
    }
  ]
}
```

---

## Rate Limiting

### Limits by Endpoint Type

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| Authentication | 5 | 1 minute |
| General API | 100 | 1 minute |
| File Upload | 50 | 1 hour |

### Rate Limit Headers

Responses include rate limit information:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1678604500
```

### Handling Rate Limits

When you hit the rate limit (429 response):

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "http_status": 429,
    "details": [
      {
        "field": "retry_after",
        "message": "Retry after 60 seconds"
      }
    ]
  }
}
```

**Strategy**:
1. Wait for `Retry-After` header value (in seconds)
2. Or wait until `X-RateLimit-Reset` timestamp
3. Retry the request

---

## Best Practices

### 1. Authentication

✅ Always include `Authorization` header:
```bash
-H "Authorization: Bearer <token>"
```

✅ Refresh token before expiration:
```bash
POST /api/auth/refresh-token
```

❌ Never send credentials in URL
❌ Never log access tokens

### 2. Error Handling

✅ Check HTTP status code
✅ Handle specific error codes
✅ Implement exponential backoff for retries

❌ Don't ignore error responses
❌ Don't assume success if status is 2xx

### 3. Pagination

✅ Use `page` and `page_size` parameters:
```
GET /api/livestock?page=1&page_size=25
```

✅ Handle `total` count in response
❌ Don't request unlimited pages

### 4. Performance

✅ Use appropriate filtering:
```
GET /api/livestock?animal_type=cattle&status=active
```

✅ Implement client-side caching
✅ Use batch operations when available

❌ Don't make unnecessary requests
❌ Don't fetch all data at once

### 5. Security

✅ Always use HTTPS in production
✅ Store tokens securely
✅ Rotate credentials regularly
✅ Validate all inputs before sending

❌ Don't hardcode credentials
❌ Don't send sensitive data in query strings
❌ Don't log tokens or passwords

---

## Examples

### Example 1: Complete Login Flow

```javascript
// 1. Login
const loginResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePass123!'
  })
});

const { access_token } = await loginResponse.json();
localStorage.setItem('token', access_token);

// 2. Get user profile
const profileResponse = await fetch('/api/auth/me', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});

const user = await profileResponse.json();
console.log('Logged in as:', user.name);

// 3. Call protected endpoint
const livestockResponse = await fetch('/api/livestock', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});

const livestock = await livestockResponse.json();
console.log('Livestock:', livestock.items);
```

### Example 2: Register New User

```bash
curl -X POST http://127.0.0.1:8001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "password": "JanePass123!",
    "confirm_password": "JanePass123!",
    "phone": "+1234567890"
  }' | json_pp
```

### Example 3: Create Livestock Batch

```bash
TOKEN="your_jwt_token_here"

curl -X POST http://127.0.0.1:8001/api/livestock \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "batch_name": "Spring Cattle 2026",
    "animal_type": "cattle",
    "count": 75,
    "acquisition_date": "2026-03-12",
    "supplier": "Quality Livestock Supplies Inc"
  }' | json_pp
```

### Example 4: Error Handling

```javascript
async function apiCall(endpoint, options = {}) {
  try {
    const response = await fetch(`/api${endpoint}`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
        'Content-Type': 'application/json',
        ...options.headers
      },
      ...options
    });

    if (!response.ok) {
      const error = await response.json();
      
      if (response.status === 401) {
        // Token expired, refresh it
        await refreshToken();
        // Retry original request
        return apiCall(endpoint, options);
      }
      
      if (response.status === 429) {
        // Rate limited
        const retryAfter = response.headers.get('Retry-After');
        throw new Error(`Rate limited. Retry after ${retryAfter} seconds`);
      }
      
      throw new Error(error.error.message);
    }

    return await response.json();
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
}
```

---

## OpenAPI/Swagger

Interactive API documentation is available at:

```
This backend does not expose Swagger/ReDoc routes.
```

Use the Swagger interface to:
- Explore all endpoints
- View request/response formats
- Test endpoints directly
- See required parameters

---

## Pagination

All list endpoints support pagination:

```
GET /api/livestock?page=2&page_size=25
```

Response includes pagination info:

```json
{
  "items": [...],
  "total": 150,
  "page": 2,
  "page_size": 25,
  "total_pages": 6
}
```

---

## Filtering & Sorting

List endpoints support filtering and sorting:

```
GET /api/livestock?animal_type=cattle&status=active&sort_by=created_at
```

Available filters depend on the endpoint. Check the specific endpoint documentation.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-12 | Initial release |

---

## Support

For API support:
- Check endpoint documentation above
- Review error codes and messages
- Check the troubleshooting guide
- Enable request logging for debugging

---

**Last Updated**: March 12, 2026  
**API Version**: 1.0.0  
**Status**: Production Ready ✅


---

