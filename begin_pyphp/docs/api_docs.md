# Begin Masimba - API Documentation

## Overview
Begin Masimba exposes a RESTful API built in PHP. This API powers the frontend and can be used for third-party integrations.

## Base URL
- WAMP/XAMPP: `http://localhost/farmos/begin_pyphp/backend`
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
