# FarmOS PHP Backend Setup Guide

## Overview

FarmOS has been converted from a FastAPI (Python) backend to a pure PHP 8.0+ backend. This guide covers setup, development, and deployment.

## System Requirements

- **PHP 8.0+** with the following extensions:
  - `php-mysql` - MySQL database support
  - `php-json` - JSON handling
  - `php-redis` - Redis caching (optional)
  - `php-curl` - HTTP requests
  - `php-fileinfo` - File type detection
  - `php-mbstring` - UTF-8 string handling

- **MySQL 8.0+** - Database server
- **Redis 7.0+** (optional) - Caching layer
- **Composer** - PHP dependency manager
- **Apache 2.4+** or **Nginx 1.20+** - Web server with PHP-FPM

## Installation

### 1. Install Dependencies

```bash
cd backend
composer install
```

This will install:
- `firebase/php-jwt` - JWT token handling
- `guzzlehttp/guzzle` - HTTP client
- Development dependencies: `phpunit`, `phpstan`, `psalm`, `phpcs`

### 2. Configure Environment

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_NAME=farmos_db
DB_USER=farmos_user
DB_PASSWORD=your_secure_password

# JWT
JWT_SECRET=your-256-bit-secret-key-minimum-64-chars
JWT_EXPIRY=3600

# Security
BCRYPT_COST=12
API_RATE_LIMIT_AUTH=5
API_RATE_LIMIT_API=100

# CORS
CORS_ORIGIN=http://localhost:3000

# Logging
LOG_DIR=/var/log/farmos
LOG_FORMAT=json
```

### 3. Create Database

```bash
mysql -u root -p < database/schema.sql
```

### 4. Create System Directories

```bash
mkdir -p /var/log/farmos
mkdir -p /var/cache/farmos/uploads
chmod -R 755 /var/log/farmos
chmod -R 755 /var/cache/farmos
```

## Project Structure

```
backend/
├── public/
│   └── index.php              # Main entry point
├── src/
│   ├── Security.php            # JWT, bcrypt, cryptography
│   ├── Database.php            # PDO connection & queries
│   ├── Request.php             # HTTP request handling
│   ├── Response.php            # JSON response formatting
│   ├── Logger.php              # Structured logging
│   ├── Validation.php          # Input validation
│   ├── RateLimiter.php         # Anti-brute force
│   ├── Auth.php                # Authentication
│   ├── Exception.php           # Custom exceptions
│   ├── Models/
│   │   ├── Model.php           # Base model class
│   │   ├── QueryBuilder.php    # Fluent query builder
│   │   └── User.php            # User model
│   └── Middleware/
│       └── Middleware.php      # Middleware classes
├── config/
│   └── env.php                # Environment configuration
├── database/
│   └── schema.sql             # Database schema
├── tests/
│   └── *.php                  # PHPUnit tests
├── .htaccess                  # Apache URL rewriting
├── composer.json              # PHP dependencies
├── .env.example               # Environment template
└── README.md                  # This file
```

## Core Classes

### Security.php (180 lines)
Handles cryptographic operations:
- `hashPassword()` - Bcrypt hashing with strength validation
- `verifyPassword()` - Timing-attack resistant verification
- `encodeJWT()` / `decodeJWT()` - JWT token management
- `getSecurityHeaders()` - HTTP security headers

### Database.php (140 lines)
Database abstraction with PDO:
- `query()` / `queryOne()` / `execute()` - SQL execution
- `beginTransaction()` / `commit()` / `rollback()` - Transactions
- Prepared statement support prevents SQL injection
- Connection pooling support

### Request.php (110 lines)
HTTP request handling:
- `getMethod()` / `getPath()` - HTTP verb and route
- `getBody()` / `getQuery()` / `getInput()` - Parameter access
- `getToken()` / `getUser()` - JWT token and decoded claims
- `getIP()` - Client IP with proxy support

### Response.php (120 lines)
JSON response factory:
- `success()` / `error()` / `notFound()` - Common responses
- `validationError()` / `rateLimited()` - Specialized responses
- Automatic security headers included

### Logger.php (80 lines)
Structured logging:
- JSON and text format support
- `info()` / `warning()` / `error()` / `debug()` methods
- Request ID tracking
- File-based with rotation

### Validation.php (140 lines)
Input validation and sanitization:
- `validateEmail()` / `validatePhone()` / `validateURL()` / `validateUUID()`
- `validatePassword()` - 8+ chars, upper/lower/digit/special
- `sanitizeString()` - XSS prevention
- Integer, date, enum validation

### RateLimiter.php (80 lines)
Sliding window rate limiting:
- `isAllowed()` - Check if under limit
- Per-identifier tracking
- Three limit tiers: auth (5/min), api (100/min), upload (50/hour)

### Auth.php (140 lines)
User authentication:
- `login()` - Email/password authentication
- `register()` - New user creation
- `getUser()` - Fetch user profile
- `refreshToken()` - Token refresh

### Model.php (250 lines)
Base database model with ORM features:
- `find()` / `all()` / `where()` - Query methods
- `save()` / `update()` / `delete()` - Data persistence
- Type casting and attribute hiding
- `isDirty()` - Track modifications

### QueryBuilder.php (200 lines)
Fluent query builder:
- `where()` / `orWhere()` / `orderBy()` - Query methods
- `limit()` / `offset()` / `paginate()` - Result limiting
- `get()` / `first()` / `count()` - Result retrieval
- `pluck()` / `distinct()` - Column operations

### Middleware.php (200 lines)
Middleware classes:
- `AuthMiddleware` - JWT verification
- `RateLimitMiddleware` - Rate limit enforcement
- `CorsMiddleware` - CORS header handling
- `AdminMiddleware` - Admin-only access
- `Pipeline` - Middleware execution

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login with email/password
- `POST /api/auth/register` - Create new account
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/refresh-token` - Refresh JWT token

### Health Check
- `GET /health` - Server health status

### Request/Response Format

**Success Response:**
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": { ... }
  }
}
```

## Development Server

### Using PHP Built-in Server
```bash
php -S localhost:8000 -t public/
```

### Using Apache with mod_php
Configure Apache vhost:
```apache
<VirtualHost *:80>
    ServerName farmos.local
    DocumentRoot /var/www/farmos/backend
    
    <Directory /var/www/farmos/backend>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### Using Nginx with PHP-FPM
Configure Nginx:
```nginx
server {
    listen 80;
    server_name farmos.local;
    root /var/www/farmos/backend/public;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

## Testing

Run tests with PHPUnit:
```bash
composer test
```

Run static analysis:
```bash
composer lint      # PHPCS
composer type-check # PHPStan
```

## Security

### Default Security Features
- ✅ Bcrypt password hashing (cost 12)
- ✅ JWT token-based authentication (HMAC-SHA256)
- ✅ Rate limiting (5 auth, 100 API, 50 upload per hour)
- ✅ Prepared statements (SQL injection prevention)
- ✅ XSS prevention (htmlspecialchars sanitization)
- ✅ CSRF token support (if needed)
- ✅ Security headers (CSP, HSTS, X-Frame-Options, etc.)
- ✅ Input validation and type checking
- ✅ Structured logging with request IDs
- ✅ Password strength validation (8+ chars, 4 complexity types)

### Environment Security
```env
# NEVER commit .env files
# Add to .gitignore:
# .env
# .env.local
# build/

# Use strong JWT secret (generate with):
# openssl rand -base64 64
JWT_SECRET=generate_strong_secret_here

# Set restrictive permissions:
chmod 600 .env
chmod 400 config/database.php
```

## Performance Optimization

### Database
- Use indexes on frequently queried columns
- Connection pooling for high traffic
- Use Redis for session caching
- Query optimization (see queries in logs)

### Caching
```php
// Cache layer (optional)
$redis = new Redis();
$redis->connect('localhost', 6379);
$cached = $redis->get('key');
```

### Compression
- Gzip enabled in .htaccess
- JSON responses use compact formatting
- Remove unnecessary whitespace

## Monitoring

### Logs
```
/var/log/farmos/
├── 2024-01-01.json         # Daily JSON logs
├── 2024-01-02.json
└── error.log               # Error-only logs
```

### Viewing Logs
```bash
# Recent errors
tail -f /var/log/farmos/error.log

# Today's activity
cat /var/log/farmos/$(date +%Y-%m-%d).json | jq .

# Find specific user
cat /var/log/farmos/*.json | jq 'select(.context.user_id == 5)'
```

## Troubleshooting

### Database Connection Failed
```php
// Check credentials in .env
// Verify MySQL is running
// Test connection manually:
$pdo = new PDO('mysql:host=localhost', 'user', 'password');
```

### JWT Token Expired
- Tokens expire after 1 hour (configurable in .env)
- Use `/api/auth/refresh-token` to extend
- Client should handle 401 responses with refresh flow

### Rate Limit Exceeded
- API limit: 100 requests/minute per IP
- Auth limit: 5 requests/minute (faster to prevent brute force)
- Headers include `Retry-After: 60`

### Permission Denied on Logs
```bash
sudo chmod 755 /var/log/farmos
sudo chown www-data:www-data /var/log/farmos
```

## Deployment
SSL/TLS configuration is handled by your web server (Apache/WAMP) or a reverse proxy in front of it.

## Migration from FastAPI

This PHP backend replaces the original FastAPI backend with:
- Same API endpoints and response format
- Same security model (bcrypt, JWT, rate limiting)
- Same database schema
- Compatible with existing frontend

Key differences:
- No virtualenv or pip installation
- PHP autoloader instead of Python imports
- `composer.json` instead of `requirements.txt`
- `.htaccess` instead of Uvicorn routing

## Contributing

Guidelines for extending the backend:

### Creating New Model
```php
class Farm extends Model
{
    protected static string $table = 'farms';
    protected static array $fillable = ['name', 'location', 'size];
}
```

### Creating New Middleware
```php
class CustomMiddleware extends Middleware
{
    public function handle(): mixed
    {
        // ... validation logic ...
        return true; // continue or Response object
    }
}
```

### Adding API Endpoints
Edit `public/index.php` and add routes:
```php
case '/api/resource':
    $auth = new AuthMiddleware($request, $db);
    if ($auth->handle() !== true) {
        return $auth->handle();
    }
    // ... handle request ...
    break;
```

## License

Same as main FarmOS project.

## Support

For issues or questions:
1. Check logs: `/var/log/farmos/`
2. Review error responses for error codes
3. Verify environment configuration
4. Check database connectivity
