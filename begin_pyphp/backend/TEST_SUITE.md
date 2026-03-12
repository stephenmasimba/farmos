# API Test Suite Documentation

## Overview

The FarmOS backend includes a comprehensive PHPUnit test suite covering:
- **Feature Tests**: API endpoint testing (46+ endpoints)
- **Unit Tests**: Core class and model testing
- **Integration Tests**: Database transactions and cross-model operations
- **Authentication Tests**: User registration, login, and token validation

**Target Coverage**: 80%+ code coverage

## Running Tests

### Prerequisites

```bash
# Install Composer dependencies (includes PHPUnit)
composer install

# Set up test database
mysql -u root -p < tests/fixtures/test_database.sql
```

### Run All Tests

```bash
# Run all test suites
composer test

# With output
phpunit --verbose

# With coverage report
composer test:coverage
```

### Run Specific Test Suite

```bash
# Feature tests only
composer test:feature

# Unit tests only
composer test:unit

# Specific test file
phpunit tests/Feature/LivestockTest.php

# Specific test method
phpunit --filter testCreateLivestock
```

## Test Structure

### Base Test Case

**File**: `tests/ApiTestCase.php`

Provides common functionality for all tests:
- Database setup/teardown
- Test user creation and authentication
- API request helper methods
- Authentication token management

### Feature Tests

Located in `tests/Feature/`, these test complete API workflows:

#### LivestockTest.php (11 tests)
- List livestock with pagination
- Create livestock record
- Get, update, delete operations
- Add and retrieve events
- Statistics aggregation
- Validation and error handling

#### InventoryTest.php (11 tests)
- List inventory items
- CRUD operations
- Quantity adjustments with logging
- Low stock alerts
- Category filtering
- Statistics and value calculations
- Expiry date tracking

#### FinancialTest.php (11 tests)
- Record income/expense transactions
- Get, update, delete records
- Monthly and yearly reporting
- Summary and forecasts
- Category filtering
- Profit margin calculations
- Type validation

#### TaskTest.php (10 tests)
- Create and manage tasks
- Status transitions (pending → in_progress → completed)
- Task assignment
- Priority filtering
- Statistics
- Overdue and due-soon tracking
- Batch operations

#### AuthenticationTest.php (8 tests)
- User registration
- Login and token generation
- Token refresh
- Current user retrieval
- Invalid credentials handling
- Rate limiting on auth endpoints
- Token validation

### Unit Tests

Located in `tests/Unit/`, these test individual classes:

```
tests/Unit/
├── ModelsTest.php
├── ValidationTest.php
├── SecurityTest.php
├── DatabaseTest.php
└── QueryBuilderTest.php
```

## Test Data & Fixtures

### Test User
- Email: `test@example.com`
- Password: `TestPassword123!`
- Created in `setUpBeforeClass()`

### Test Farm
- Created automatically for each test
- Linked to test user
- Used as parent for all operations

### Test Database
- Separate test database: `farmos_test`
- Created fresh before each test run
- Destroyed after tests complete
- Uses MySQL 8.0+

## Coverage Report

Generate and view HTML coverage report:

```bash
composer test:coverage
open build/coverage/index.html
```

Coverage metrics per component:

| Component | Target | Current |
|-----------|--------|---------|
| Controllers | 85% | - |
| Models | 90% | - |
| Middleware | 80% | - |
| Validation | 85% | - |
| Database | 75% | - |
| Security | 95% | - |
| **Overall** | **80%** | - |

## Continuous Integration

### GitHub Actions Workflow

File: `.github/workflows/test.yml`

Runs on:
- Every push to main/develop
- Every pull request
- Scheduled daily at 2 AM UTC

Test matrix:
- PHP 8.0, 8.1, 8.2
- MySQL 5.7, 8.0, 8.1

## Mock Objects

Using Mockery for unit tests:

```php
// Mock a Database instance
$db = Mockery::mock(Database::class);
$db->shouldReceive('query')
    ->andReturn([['id' => 1, 'name' => 'Test']]);

// Mock HTTP requests
$request = Mockery::mock(Request::class);
$request->shouldReceive('getBody')
    ->andReturn(['name' => 'Bessie']);
```

## API Response Format

All endpoints return standardized JSON:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ },
  "errors": null
}
```

Error response:

```json
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "errors": {
    "field_name": "Error message"
  }
}
```

## Best Practices

### Writing Tests

1. **Use descriptive names**: `testCreateLivestockWithValidData()`
2. **Test one assertion per test** when possible
3. **Use `setUp()`** for test initialization
4. **Clean up in `tearDown()`** if needed
5. **Test both success and failure cases**

### Test Organization

```php
public function testOperationSuccess(): void
{
    // Arrange - Set up test data
    $data = [...];
    
    // Act - Perform operation
    $response = $this->apiCall('POST', '/api/endpoint', $data);
    
    // Assert - Verify results
    $this->assertEquals(201, $response['status']);
}
```

### Assertions

Common assertions:

```php
$this->assertEquals($expected, $actual);
$this->assertArrayHasKey('key', $array);
$this->assertNotNull($value);
$this->assertTrue($condition);
$this->assertCount(3, $array);
$this->assertStringContains('substring', $string);
```

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
