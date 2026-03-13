# FarmOS API Documentation

**Version**: 1.0.0  
**Last Updated**: March 12, 2026  
**Base URL**: `http://localhost/farmos/begin_pyphp/backend/api` (WAMP) | `http://127.0.0.1:8001/api` (Built-in) | `https://api.yourdomain.com/api` (Production)

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
