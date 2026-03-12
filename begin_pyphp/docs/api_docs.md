# Begin Masimba - API Documentation

## Overview
Begin Masimba exposes a RESTful API built with FastAPI. This API powers the frontend and can be used for third-party integrations.

## Interactive Documentation
The API comes with built-in interactive documentation powered by Swagger UI and ReDoc.

- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs) - Test endpoints directly from your browser.
- **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc) - Clean, organized reference documentation.

## Authentication
All API endpoints (except login/registration) require authentication.

### Headers
Include the following headers in your requests:
- `Authorization`: `Bearer <your_access_token>`
- `X-API-Key`: `local-dev-key` (or your production API key)
- `X-Tenant-ID`: `1` (or your specific tenant ID)

### Obtaining a Token
1. Send a POST request to `/api/auth/token` with your username and password.
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
- `POST /api/iot/ingest`: Ingest sensor data (requires API Key).

## Error Handling
The API returns standard HTTP status codes:
- `200 OK`: Success.
- `201 Created`: Resource created successfully.
- `400 Bad Request`: Invalid input.
- `401 Unauthorized`: Missing or invalid authentication.
- `403 Forbidden`: Insufficient permissions.
- `404 Not Found`: Resource not found.
- `500 Internal Server Error`: Server-side issue.
