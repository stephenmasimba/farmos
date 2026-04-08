# Backend Engineering Notes Consolidated

Generated: 2026-04-08 15:57:53

---

## Source: C:\wamp64\www\farmos\app\backend\PHP_BACKEND_README.md

# FarmOS PHP Backend Setup Guide

## Overview

FarmOS uses a pure PHP 8.0+ backend. This guide covers setup, development, and deployment.

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
CORS_ORIGIN=http://localhost

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
  "id": 123
}
```

**Error Response:**
```json
{
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
composer run serve
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
composer run test
```

Run static analysis:
```bash
composer run lint       # PHPCS
composer run type-check # PHPStan
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

## Migration Notes

This PHP backend replaces the previous backend with:
- Same API endpoints and response format
- Same security model (bcrypt, JWT, rate limiting)
- Same database schema
- Compatible with existing frontend

Key differences:
- No separate runtime to install
- PHP autoloader instead of language-level imports
- `composer.json` instead of `requirements.txt`
- `.htaccess` rewrite routing (or web server rewrite rules)

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


---

## Source: C:\wamp64\www\farmos\app\backend\QUICK_REFERENCE.md

# PHP Backend Quick Reference

A quick lookup guide for common FarmOS PHP backend operations.

## Starting the Backend

### PHP Built-in Server (Development)
```bash
cd backend
composer run serve
```

## Testing API

### Health Check
```bash
curl http://127.0.0.1:8001/health
```

### Login (Get Token)
```bash
curl -X POST http://127.0.0.1:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123"
  }'
```

### Use Token in Requests
```bash
TOKEN="<your_jwt_token>"

curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8001/api/auth/me
```

### Register New User
```bash
curl -X POST http://127.0.0.1:8001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecureP@ss123",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

## Creating New Models

### Basic Model Template
```php
<?php
namespace FarmOS\Models;

use FarmOS\Database;

class YourModel extends Model
{
    protected static string $table = 'table_name';
    protected static array $fillable = ['field1', 'field2'];
    protected static array $casts = [
        'id' => 'int',
        'created_at' => 'datetime',
    ];
}
```

### Using Models in Code
```php
// Create
$model = new YourModel($db, [
    'field1' => 'value1',
    'field2' => 'value2'
]);
$model->save();

// Read
$model = YourModel::find(1, $db);
$models = YourModel::all($db);
$model = YourModel::where('email', 'user@example.com', $db);

// Update
$model->field1 = 'new value';
$model->save();

// Delete
$model->delete();
// or
YourModel::destroy(1, $db);

// Query
$results = YourModel::query($db)
    ->where('status', 'active')
    ->orderBy('created_at', 'DESC')
    ->limit(10)
    ->get();
```

## Creating New Controllers

### Basic Controller Pattern
```php
<?php
namespace FarmOS\Controllers;

use FarmOS\{Request, Response, Database};
use FarmOS\Models\YourModel;

class YourController
{
    protected Database $db;
    protected Request $request;

    public function __construct(Database $db, Request $request)
    {
        $this->db = $db;
        $this->request = $request;
    }

    // List all
    public function index(): Response
    {
        $items = YourModel::all($this->db);
        return Response::success(['items' => $items]);
    }

    // Create
    public function store(): Response
    {
        $input = $this->request->getBody();
        
        // Validate
        if (empty($input['field1'])) {
            return Response::validationError(['field1' => 'Required']);
        }

        // Save
        $model = new YourModel($this->db, $input);
        $id = $model->save();

        return Response::json(['id' => $id], 201);
    }

    // Get one
    public function show($id): Response
    {
        $model = YourModel::find($id, $this->db);
        if (!$model) {
            return Response::notFound();
        }
        return Response::success($model->toArray());
    }

    // Update
    public function update($id): Response
    {
        $model = YourModel::find($id, $this->db);
        if (!$model) {
            return Response::notFound();
        }

        $input = $this->request->getBody();
        foreach ($input as $key => $value) {
            $model->{$key} = $value;
        }
        $model->save();

        return Response::success(['message' => 'Updated']);
    }

    // Delete
    public function destroy($id): Response
    {
        $affected = YourModel::destroy($id, $this->db);
        if (!$affected) {
            return Response::notFound();
        }
        return Response::success(['message' => 'Deleted']);
    }
}
```

### Adding Controller to Router

In `public/index.php`:
```php
$yourController = new \FarmOS\Controllers\YourController($db, $request);

switch ($path) {
    case '/api/your-resource':
        if ($method === 'GET') {
            $yourController->index()->send();
        } elseif ($method === 'POST') {
            $yourController->store()->send();
        }
        break;

    case (preg_match('/^\/api\/your-resource\/(\d+)$/', $path, $matches) ? true : false):
        $id = $matches[1];
        if ($method === 'GET') {
            $yourController->show($id)->send();
        } elseif ($method === 'PUT') {
            $yourController->update($id)->send();
        } elseif ($method === 'DELETE') {
            $yourController->destroy($id)->send();
        }
        break;
}
```

## Input Validation

### Using Validation Class
```php
use FarmOS\Validation;

// Email
if (!Validation::validateEmail($email)) {
    return Response::validationError(['email' => 'Invalid email']);
}

// Password strength
if (!Validation::validatePassword($password)) {
    return Response::validationError(['password' => 'Password too weak']);
}

// URL
if (!Validation::validateURL($url)) {
    return Response::validationError(['url' => 'Invalid URL']);
}

// Phone
if (!Validation::validatePhone($phone)) {
    return Response::validationError(['phone' => 'Invalid phone number']);
}

// String sanitization (XSS prevention)
$clean = Validation::sanitizeString($userInput);

// UUID
if (!Validation::validateUUID($uuid)) {
    return Response::validationError(['uuid' => 'Invalid UUID']);
}

// Integer
if (!Validation::validateInteger($number, 1, 100)) {
    return Response::validationError(['number' => 'Must be 1-100']);
}

// Date
if (!Validation::validateDate($date, 'Y-m-d')) {
    return Response::validationError(['date' => 'Invalid date format']);
}

// Enum
if (!Validation::validateEnum($status, ['active', 'inactive'])) {
    return Response::validationError(['status' => 'Invalid status']);
}
```

## Database Queries

### Direct Database Access
```php
// Query (returns multiple rows)
$results = $db->query(
    'SELECT * FROM users WHERE status = ? ORDER BY created_at DESC',
    ['active']
);

// QueryOne (returns single row or null)
$result = $db->queryOne(
    'SELECT * FROM users WHERE email = ?',
    ['user@example.com']
);

// Execute (INSERT, UPDATE, DELETE)
$affected = $db->execute(
    'UPDATE users SET status = ? WHERE id = ?',
    ['active', 1]
);

// Insert and get ID
$db->execute('INSERT INTO users (email) VALUES (?)', ['new@example.com']);
$id = $db->lastInsertId();
```

### Transactions
```php
$db->beginTransaction();

try {
    // Do multiple operations
    $db->execute('UPDATE users SET balance = balance - ? WHERE id = ?', [100, 1]);
    $db->execute('UPDATE accounts SET balance = balance + ? WHERE id = ?', [100, 2]);
    
    $db->commit(); // Save all changes
} catch (Exception $e) {
    $db->rollback(); // Undo all changes
    throw $e;
}
```

## Middleware Usage

### Protect a Route with Auth
```php
$auth = new \FarmOS\Middleware\AuthMiddleware($request, $db);
$result = $auth->handle();

if ($result !== true) {
    return $result; // Return the unauthorized response
}
// User is authenticated, continue
```

### Check Admin Only
```php
$admin = new \FarmOS\Middleware\AdminMiddleware($request, $db);
if ($admin->handle() !== true) {
    return $admin->handle();
}
// User is admin, continue
```

### Rate Limiting
```php
$rateLimit = new \FarmOS\Middleware\RateLimitMiddleware(
    $request,
    $db,
    'auth' // or 'api' or 'upload'
);
if ($rateLimit->handle() !== true) {
    return $rateLimit->handle();
}
// Under rate limit, continue
```

### Pipeline (Multiple Middleware)
```php
$pipeline = new \FarmOS\Middleware\Pipeline($request, $db);
$result = $pipeline
    ->add('CorsMiddleware')
    ->add('AuthMiddleware')
    ->add('AdminMiddleware')
    ->execute();

if ($result !== true) {
    return $result; // One middleware blocked
}
// All middleware passed, continue
```

## Logging

### Basic Logging
```php
use FarmOS\Logger;

Logger::info('User login', ['user_id' => 1, 'email' => 'user@example.com']);
Logger::warning('Low disk space', ['available_gb' => 5]);
Logger::error('Database connection failed', ['host' => 'localhost']);
Logger::debug('Query executed', ['query' => 'SELECT * FROM users', 'time_ms' => 52]);
```

### With Request ID (for tracing)
```php
Logger::info('Request processed', [
    'request_id' => '123abc',
    'user_id' => 1,
    'endpoint' => '/api/users',
    'method' => 'GET',
    'status' => 200,
]);
```

## Common Responses

### Success Response
```php
Response::success([
    'id' => 1,
    'name' => 'John',
    'email' => 'john@example.com'
], 'User retrieved successfully')->send();
```

### Validation Error
```php
Response::validationError([
    'email' => 'Email is required',
    'password' => 'Password must be 8+ characters'
])->send();
```

### Not Found
```php
Response::notFound('Resource not found')->send();
```

### Unauthorized
```php
Response::unauthorized('Invalid credentials')->send();
```

### Forbidden
```php
Response::forbidden('You do not have permission')->send();
```

### Rate Limited
```php
Response::rateLimited(60) // retry after 60 seconds
    ->send();
```

### Server Error
```php
Response::error(
    'Something went wrong',
    'INTERNAL_ERROR',
    500
)->send();
```

## Testing

### Run All Tests
```bash
composer test
```

### Run Specific Test
```bash
./vendor/bin/phpunit tests/Unit/SecurityTest.php
```

### Run with Coverage
```bash
./vendor/bin/phpunit --coverage-html build/coverage/
```

### Run Code Quality Checks
```bash
composer lint       # PHPCS
composer type-check # PHPStan
```

## Database Debugging

### View Logs
```bash
# All logs
tail -f /var/log/farmos/*.json | jq .

# Errors only
cat /var/log/farmos/error.log

# By date
cat /var/log/farmos/2024-01-15.json | jq .

# By user
cat /var/log/farmos/*.json | jq 'select(.context.user_id == 5)'

# By endpoint
cat /var/log/farmos/*.json | jq 'select(.context.endpoint | contains("livestock"))'
```

### Test Database Connection
```php
$db = Database::init(
    getenv('DATABASE_URL'),
    getenv('DB_USER'),
    getenv('DB_PASSWORD')
);

if ($db->test()) {
    echo "Connected!";
} else {
    echo "Failed!";
}
```

## Environment Variables

### Critical Settings
```env
# Database
DATABASE_URL=mysql:host=localhost;port=3306;dbname=farmos_db
DB_USER=farmos_user
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your-long-secret-key-of-64-chars-minimum

# Security
BCRYPT_COST=12
API_RATE_LIMIT_AUTH=5
API_RATE_LIMIT_API=100
API_RATE_LIMIT_UPLOAD=50

# CORS
CORS_ORIGIN=http://localhost:3000

# Logging
LOG_DIR=/var/log/farmos
LOG_FORMAT=json
LOG_LEVEL=info
```

## Useful Commands

```bash
# Install dependencies
composer install

# Update dependencies
composer update

# Start dev server
composer run serve

# Run tests
composer run test

# Check code style
composer run lint

# Type checking
composer run type-check

# View logs
tail -f /var/log/farmos/*.json

# Check database
mysql -u farmos_user -p farmos_db

# Create .env from template
cp .env.example .env
```

## File Structure Reference

```
backend/
├── public/
│   └── index.php              ← Entry point, routes
├── src/
│   ├── Security.php           ← JWT, bcrypt, crypto
│   ├── Database.php           ← Database operations
│   ├── Request.php            ← HTTP request parsing
│   ├── Response.php           ← JSON responses
│   ├── Logger.php             ← Structured logging
│   ├── Validation.php         ← Input validation
│   ├── RateLimiter.php        ← Rate limiting
│   ├── Auth.php               ← Authentication
│   ├── Exception.php          ← Custom exceptions
│   ├── Models/
│   │   ├── Model.php          ← Base ORM
│   │   ├── QueryBuilder.php   ← Query building
│   │   └── User.php           ← User model
│   ├── Controllers/
│   │   └── (Controllers here)
│   └── Middleware/
│       └── Middleware.php     ← All middleware
├── config/
│   └── env.php                ← Config loader
├── tests/
│   └── (Tests here)
├── .env                       ← Environment (gitignored)
├── .env.example               ← Template
├── composer.json              ← Dependencies
├── .htaccess                  ← URL rewriting
└── README files               ← Documentation
```

## Common Errors & Solutions

### "Class not found"
- Check namespace matches directory structure
- Verify PSR-4 autoloader in composer.json
- Run `composer dump-autoload`

### "Database connection failed"
- Check credentials in .env
- Verify MySQL is running
- Check database exists and user has permissions

### "JWT token invalid"
- Check JWT_SECRET in .env
- Verify token not expired (1 hour default)
- Use refresh endpoint to get new token

### "Rate limit exceeded"
- Wait the specified time
- Check rate limit tiers in RateLimiter.php
- Increase limits in .env if needed

### "Permission denied on logs"
- Fix ownership: `sudo chown www-data:www-data /var/log/farmos`
- Fix permissions: `chmod 755 /var/log/farmos`

## Related Documentation

- Setup: [PHP_BACKEND_README.md](PHP_BACKEND_README.md)
- Status: [PHP_BACKEND_STATUS.md](PHP_BACKEND_STATUS.md)
- Progress: [SESSION_SUMMARY.md](SESSION_SUMMARY.md)
- Tasks: [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)

---

**Last Updated**: Latest Development Session
**Version**: PHP 8.0+
**Status**: Production Ready (Core Infrastructure)


---

## Source: C:\wamp64\www\farmos\app\backend\TEST_SUITE.md

# API Test Suite Documentation

## Overview

The backend includes a PHPUnit suite focused on feature tests for the HTTP API:
- Authentication
- Financial records
- Inventory
- Livestock (including events)
- Tasks

## Requirements

- PHP 7.4+ and Composer
- MySQL running locally
- A MySQL user that can create/drop databases (tests create `farmos_test`)

## Running Tests

From `app/backend`:

```bash
composer install
composer run test
```

Run a single test file:

```bash
vendor/bin/phpunit tests/Feature/LivestockTest.php
```

Run a single test method:

```bash
vendor/bin/phpunit --filter testCreateLivestock tests/Feature/LivestockTest.php
```

## Test Structure

- `tests/ApiTestCase.php` creates and migrates the `farmos_test` database, and creates a test user with an auth token.
- `tests/Feature/*.php` contains the endpoint-level tests:
  - `AuthenticationTest.php`
  - `FinancialTest.php`
  - `InventoryTest.php`
  - `LivestockTest.php`
  - `TaskTest.php`

## API Response Shape

Success responses return the payload directly (no wrapper key). Error responses follow:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
```

## Common Issues

### Database Setup Fails

The suite reads DB connection settings from environment variables (with sensible defaults). If your MySQL setup differs, set:
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`

### Permission Errors Creating `farmos_test`

Grant your MySQL user permission to create/drop databases for local testing, or run the suite with a MySQL user that already has these permissions.

## Troubleshooting

### Database Connection Errors

```
Error: No such file or directory
```

**Solution**: Check `.env` file has valid database credentials

### Test Isolation Issues

```
Error: Duplicate entry for key 'email'
```

**Solution**: Ensure test cleanup runs properly; check `tearDownAfterClass()`

### Timeout Issues

For slow tests, adjust in `phpunit.xml`:

```xml
<php>
    <ini name="max_execution_time" value="300" />
</php>
```

### Memory Errors

```
Fatal error: Allowed memory size exhausted
```

**Solution**: Increase PHP memory limit in `phpunit.xml`:

```xml
<ini name="memory_limit" value="512M" />
```

## Coverage Targets

### Per Component

**Controllers** (85% target)
- Happy path operations
- Validation error handling
- Authorization checks
- Edge cases

**Models** (90% target)
- Query methods
- Relationships
- Status indicators
- Calculation methods

**Middleware** (80% target)
- Authentication/Authorization
- Rate limiting
- CORS handling
- Request validation

**Validation** (85% target)
- Each validator
- Edge cases
- Type coercion
- Error messages

## Adding New Tests

### Checklist

- [ ] Create test file in appropriate directory
- [ ] Extend `ApiTestCase` for feature tests
- [ ] Set up test data in `setUp()`
- [ ] Test both success and failure paths
- [ ] Add validation tests
- [ ] Document test purpose
- [ ] Verify coverage for new code

### Template

```php
<?php declare(strict_types=1);

namespace Tests\Feature;

use Tests\ApiTestCase;

class YourTest extends ApiTestCase
{
    private int $farmId;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->farmId = $this->getTestFarmId();
    }
    
    public function testFeature(): void
    {
        // Arrange
        $data = [...];
        
        // Act
        $response = $this->apiCall('POST', '/api/endpoint', $data);
        
        // Assert
        $this->assertEquals(201, $response['status']);
    }
}
```

## Fast Testing

Run only changed tests:

```bash
phpunit --order-by=defects
```

Run tests in parallel (requires PHPUnit Extension):

```bash
phpunit-parallel
```

Stop at first failure:

```bash
phpunit --stop-on-failure
```

## Resources

- [PHPUnit Documentation](https://docs.phpunit.de/en/9.5/)
- [Testing Best Practices](https://docs.phpunit.de/en/9.5/writing-tests-for-phpunit.html)
- [Code Coverage](https://docs.phpunit.de/en/9.5/code-coverage-analysis.html)
- [Mockery Documentation](https://docs.mockery.io/)


---

## Source: C:\wamp64\www\farmos\app\backend\CONTROLLERS_PHASE_START.md

# Controllers Phase - Progress Update

**Date**: March 12, 2026
**Status**: Controllers Phase Initiated

## Completed

### LivestockController ✅
**File**: `src/Controllers/LivestockController.php` (380 lines)

**Endpoints Implemented**:
- `GET /api/livestock?farm_id={id}&page={page}&status={status}&species={species}` - List livestock with filters
- `POST /api/livestock` - Create new animal
- `GET /api/livestock/{id}` - Get detailed animal profile
- `PUT /api/livestock/{id}` - Update animal information
- `DELETE /api/livestock/{id}` - Archive animal (soft delete)
- `GET /api/livestock/{id}/events` - Get animal event history
- `POST /api/livestock/{id}/events` - Add event to animal
- `GET /api/livestock/stats?farm_id={id}` - Get livestock statistics

**Features**:
- ✅ Full CRUD operations
- ✅ Pagination (15 per page, max 100)
- ✅ Filtering by status (active, sold, deceased, quarantine)
- ✅ Filtering by species
- ✅ Event tracking (birth, health events, etc.)
- ✅ Statistics aggregation
- ✅ Input validation and sanitization
- ✅ Comprehensive logging
- ✅ Authentication checks
- ✅ Error handling
- ✅ Soft deletion (archived status)

**Livestock Model** ✅
**File**: `src/Models/Livestock.php` (180 lines)

**Features**:
- Fields: farm_id, name, species, breed, birth_date, gender, weight, status, acquisition_date, acquisition_cost, notes, photo_url, tag_number, microchip_id
- Methods:
  - `byFarm()` - Get livestock for a farm
  - `byStatus()` - Filter by status
  - `bySpecies()` - Filter by species
  - `activeFarm()` - Get active animals
  - `countByFarm()` - Count total
  - `countByStatus()` - Count by status
  - `getEvents()` - Retrieve event history
  - `addEvent()` - Record new event
  - `getAge()` - Calculate age in years
  - `getFullProfile()` - Complete profile with events
  - `isActive()` / `updateStatus()` - Status helpers

**Farm Model** ✅
**File**: `src/Models/Farm.php` (115 lines)

**Features**:
- Fields: owner_id, name, location, city, state, country, zip_code, latitude, longitude, size, size_unit, type, established_year, description, logo_url, phone, email
- Methods:
  - `byOwner()` - Get farms by owner
  - `byType()` - Filter by farm type
  - `getLivestock()` - Get farm's animals
  - `livestockCount()` - Count animals
  - `getFullProfile()` - Profile with statistics

**Router Updated** ✅
**File**: `public/index.php`

Added routing for all livestock endpoints with:
- Authentication middleware integration
- Proper HTTP method checking
- Regex-based route matching
- Exception handling

## Statistics

| Metric | Count |
|--------|-------|
| New Controllers | 1 |
| New Models | 2 |
| API Endpoints | 8 |
| Lines of Code (Controller) | 380 |
| Lines of Code (Models) | 295 |
| Lines of Code (Router update) | ~90 |
| **Total New Code** | **765 lines** |

## Testing

To test the livestock endpoints:

```bash
# List livestock
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://127.0.0.1:8001/api/livestock?farm_id=1"

# Create livestock
curl -X POST http://127.0.0.1:8001/api/livestock \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "farm_id": 1,
    "name": "Holstein 01",
    "species": "cattle",
    "breed": "Holstein",
    "birth_date": "2023-01-15",
    "gender": "female",
    "status": "active"
  }'

# Get animal details
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://127.0.0.1:8001/api/livestock/1"

# Get statistics
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://127.0.0.1:8001/api/livestock/stats?farm_id=1"

# Add event
curl -X POST http://127.0.0.1:8001/api/livestock/1/events \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "event_type": "vaccination",
    "description": "Annual vaccination administered",
    "date": "2026-03-12"
  }'
```

## Next - Remaining Controllers

### Priority Order (by importance to farm operations):

1. ~~**InventoryController**~~ ✅ (COMPLETE)
   - ✅ CRUD for inventory items
   - ✅ Quantity adjustments
   - ✅ Category filtering
   - ✅ Stock level alerts
   - ✅ Expiry date tracking

2. **FinancialController** (next) - Track income/expenses
   - CRUD for financial records
   - Expense and income categorization
   - Financial reporting
   - Summary statistics

3. **TaskController** - Farm task management
   - Create/update tasks
   - Assign to users
   - Mark complete
   - Priority levels

4. **DashboardController** - Aggregate statistics
   - Farm overview
   - Animal statistics
   - Financial summary
   - Inventory alerts

5. **WeatherController** - Weather data (optional)
   - Record observations
   - Track conditions
   - Forecasting

## Code Quality Checklist

✅ Input validation on all endpoints
✅ SQL injection prevention (prepared statements)
✅ XSS prevention (sanitization)
✅ Authentication checks
✅ CORS compatible
✅ Proper HTTP methods
✅ Error handling
✅ Comprehensive logging
✅ Type hints
✅ Documentation comments

## Database Requirements

Models expect existing tables:
- `farms` table with required fields
- `livestock` table with required fields
- `inventory` table with required fields
- `animal_events` table with (id, livestock_id, event_type, description, date)

If tables don't exist yet, database schema file should be created at `database/schema.sql`.

## InventoryController ✅

**File**: `src/Controllers/InventoryController.php` (450 lines)

**Endpoints Implemented**:
- `GET /api/inventory?farm_id={id}&page={page}&category={category}&status={status}` - List inventory with filters
- `POST /api/inventory` - Create inventory item
- `GET /api/inventory/{id}` - Get item details
- `PUT /api/inventory/{id}` - Update item
- `DELETE /api/inventory/{id}` - Delete item
- `GET /api/inventory/category/{category}?farm_id={id}` - Get items by category
- `POST /api/inventory/{id}/adjust` - Adjust quantity
- `GET /api/inventory/alerts?farm_id={id}` - Get low stock & expiring items
- `GET /api/inventory/stats?farm_id={id}` - Get inventory statistics

**Inventory Model** (240 lines)

Features:
- Fields: farm_id, name, category, description, quantity, unit, min_level, max_level, cost_per_unit, supplier, location, expiry_date, batch_number, notes
- Methods:
  - `byFarm()` - Get inventory for farm
  - `byCategory()` - Filter by category
  - `lowStock()` - Items below minimum
  - `expiringSoon()` - Items expiring in N days
  - `categories()` - Get all categories
  - `countByFarm()` - Count items
  - `totalValue()` - Get total inventory value
  - `adjustQuantity()` - Adjust with logged reason
  - `isLowStock()` / `isExpired()` - Status checks
  - `getValue()` - Item total value
  - `getFullProfile()` - Complete profile with status

**Testing Examples**:

```bash
# List inventory
curl -H "Authorization: Bearer TOKEN" \
  "http://127.0.0.1:8001/api/inventory?farm_id=1"

# Create inventory item
curl -X POST http://127.0.0.1:8001/api/inventory \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "farm_id": 1,
    "name": "Hay Bales",
    "category": "feed",
    "quantity": 100,
    "unit": "bales",
    "min_level": 20,
    "cost_per_unit": 5.50
  }'

# Adjust quantity
curl -X POST http://127.0.0.1:8001/api/inventory/1/adjust \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "amount": -25,
    "reason": "Used for feeding"
  }'

# Get alerts
curl -H "Authorization: Bearer TOKEN" \
  "http://127.0.0.1:8001/api/inventory/alerts?farm_id=1"

# Get statistics
curl -H "Authorization: Bearer TOKEN" \
  "http://127.0.0.1:8001/api/inventory/stats?farm_id=1"
```

## Deployment Notes

- Controllers require database initialization
- Farm, Livestock, and Inventory models depend on database schema
- Authentication middleware required for all endpoints
- Rate limiting applies (100 requests/minute default)
- Logging to `/var/log/farmos/`

## Summary

**Controllers Phase is now 25% complete** (2 of 8 controllers):

✅ Livestock management system (8 endpoints)
✅ Inventory management system (9 endpoints)
⏳ Next: Financial tracking system
⏳ Remaining: 5 more controllers

Total estimated time to complete all controllers: **3-4 days**

---

**Current Progress**: 
- Session started with core infrastructure complete → 45% overall
- Now with Livestock controller and models → **50% overall**
- Controllers phase beginning with foundation in place


---

