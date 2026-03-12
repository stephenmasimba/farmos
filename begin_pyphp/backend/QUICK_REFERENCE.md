# PHP Backend Quick Reference

A quick lookup guide for common FarmOS PHP backend operations.

## Starting the Backend

### PHP Built-in Server (Development)
```bash
cd backend
php -S localhost:8000 -t public/
```

## Testing API

### Health Check
```bash
curl http://localhost:8000/health
```

### Login (Get Token)
```bash
curl -X POST http://localhost:8000/api/auth/login \
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
  http://localhost:8000/api/auth/me
```

### Register New User
```bash
curl -X POST http://localhost:8000/api/auth/register \
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
            return Response::validationError(['field1']);
        }

        // Save
        $model = new YourModel($this->db, $input);
        $id = $model->save();

        return Response::success(['id' => $id], 'Created', 201);
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
php -S localhost:8000 -t public/

# Run tests
composer test

# Check code style
composer lint

# Type checking
composer type-check

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
