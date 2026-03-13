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

From `begin_pyphp/backend`:

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
