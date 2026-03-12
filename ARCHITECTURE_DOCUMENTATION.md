# FarmOS Architecture Documentation

**Version**: 1.0.0  
**Date**: March 12, 2026  
**Status**: Complete

---

## 📐 System Architecture Overview

This document describes the complete system architecture of FarmOS including component relationships, data flow, and deployment structure.

---

## 1. High-Level Architecture

### System Components Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        CLIENT APPLICATIONS                   │
├─────────────────┬─────────────────┬──────────────────────────┤
│                 │                 │                          │
│   PHP Frontend  │  React Web App  │    Mobile Apps           │
│   (WAMP)        │  (Future)       │    (React Native)        │
│                 │                 │                          │
└────────┬────────┴────────┬────────┴─────────────┬────────────┘
         │                 │                      │
         │ HTTP/REST       │ HTTP/REST            │ HTTP/REST
         │                 │                      │
   ┌─────▼──────────────────▼──────────────────────▼──────┐
   │                   NGINX REVERSE PROXY                │
   │          (Load Balancing, SSL/TLS, Compression)      │
   └──────────────────┬───────────────────────────────────┘
                      │
         ┌────────────▼────────────┐
         │   API GATEWAY LAYER     │
         │ (Rate Limiting, Auth)   │
         └────────────┬────────────┘
                      │
   ┌──────────────────▼──────────────────┐
   │        FASTAPI BACKEND (Python)     │
   │                                     │
   │  ┌──────────────────────────────┐   │
   │  │    Routers/Controllers       │   │
   │  │ • Auth        • Livestock    │   │
   │  │ • Inventory   • Financial    │   │
   │  │ • IoT         • Dashboard    │   │
   │  │ • 20+ modules                │   │
   │  └──────────────────────────────┘   │
   │                                     │
   │  ┌──────────────────────────────┐   │
   │  │    Business Logic Layer      │   │
   │  │ • Validation          • Auth │   │
   │  │ • Error Handling      • Rate │   │
   │  │ • Logging             Limit  │   │
   │  └──────────────────────────────┘   │
   │                                      │
   │  ┌──────────────────────────────┐   │
   │  │   Data Access (SQLAlchemy)   │   │
   │  │ • ORM Queries                │   │
   │  │ • Relationships              │   │
   │  │ • Transaction Management     │   │
   │  └──────────────────────────────┘   │
   └──────────────────┬───────────────────┘
                      │
         ┌────────────┴─────────────┐
         │                         │
   ┌─────▼──────┐           ┌─────▼──────┐
   │  MySQL DB  │           │   Redis    │
   │            │           │            │
   │ • Tables   │           │ • Cache    │
   │ • Indexes  │           │ • Sessions │
   │ • Backups  │           │ • Limits   │
   └────────────┘           └────────────┘
         │                         │
         └────────────┬────────────┘
                      │
         ┌────────────▼────────────┐
         │   MONITORING LAYER      │
         │ • Logs, Metrics, Alerts │
         └─────────────────────────┘
```

---

## 2. Application Layer Architecture

### Backend Module Organization

```
backend/
│
├── common/               # Shared utilities
│   ├── security.py       # JWT, API keys, password hashing
│   ├── errors.py         # Error handling & responses
│   ├── validation.py     # Input validation & sanitization
│   ├── logging_config.py # Structured logging
│   ├── config.py         # Configuration management
│   ├── database.py       # Database connection & ORM
│   ├── dependencies.py   # FastAPI dependencies
│   └── models.py         # SQLAlchemy ORM models
│
├── middleware/           # Middleware components
│   └── rate_limiting.py  # Anti-brute force protection
│
├── routers/              # API route handlers (30+ files)
│   ├── auth.py           # Authentication
│   ├── livestock.py      # Livestock management
│   ├── inventory.py      # Inventory tracking
│   ├── dashboard.py      # Dashboard & analytics
│   ├── financial.py      # Financial operations
│   ├── iot.py            # IoT sensor data
│   └── [20+ more...]
│
├── services/             # Business logic layer (future)
│   └── [service classes]
│
├── repositories/         # Data access layer (future)
│   └── [repository classes]
│
├── tests/                # Test suite
│   ├── conftest.py       # Test configuration
│   └── test_*.py         # Test modules
│
├── app.py                # FastAPI application instance
├── requirements.txt      # Python dependencies
├── .env.example          # Environment template
└── .gitignore            # Git configuration
```

---

## 3. Data Flow Architecture

### Request/Response Flow

```
┌─────────────┐
│   Client    │
│ (Browser)   │
└──────┬──────┘
       │
       │ 1. HTTP Request
       │ (auth, livestock, etc.)
       ▼
┌─────────────────────────┐
│  NGINX Reverse Proxy    │
│ • SSL/TLS               │
│ • Compression           │
│ • Rate Limiting         │
└──────┬──────────────────┘
       │
       │ 2. Forward to API
       ▼
┌────────────────────────────┐
│   API Gateway/Middleware   │
│ • API Key validation       │
│ • CORS handling            │
│ • Request logging          │
└──────┬─────────────────────┘
       │
       │ 3. Route Request
       ▼
┌────────────────────────────┐
│   FastAPI Router           │
│ • URL pattern matching     │
│ • HTTP method routing      │
│ • Parameter extraction     │
└──────┬─────────────────────┘
       │
       │ 4. Authenticate & Authorize
       ▼
┌────────────────────────────┐
│   Security Layer           │
│ • JWT token verification   │
│ • API key validation       │
│ • Role-based access        │
└──────┬─────────────────────┘
       │
       │ 5. Validate Input
       ▼
┌────────────────────────────┐
│   Validation Layer         │
│ • Pydantic validation      │
│ • Custom validators        │
│ • Input sanitization       │
└──────┬─────────────────────┘
       │
       │ 6. Process Business Logic
       ▼
┌────────────────────────────┐
│   Handler Function         │
│ • Business logic           │
│ • Data transformations     │
│ • Calculations             │
└──────┬─────────────────────┘
       │
       │ 7. Access Database
       ▼
┌────────────────────────────┐
│   SQLAlchemy ORM           │
│ • Build SQL queries        │
│ • Manage relationships      │
│ • Handle transactions       │
└──────┬─────────────────────┘
       │
       │ 8. Execute Query
       ▼
┌────────────────────────────┐
│   MySQL Database           │
│ • Execute SQL              │
│ • Return result set        │
│ • Handle constraints       │
└──────┬─────────────────────┘
       │
       │ 9. Return Data
       ▼
┌────────────────────────────┐
│   Handler Function         │
│ • Format response          │
│ • Apply transformations    │
│ • Include metadata         │
└──────┬─────────────────────┘
       │
       │ 10. JSON Serialization
       ▼
┌────────────────────────────┐
│   FastAPI Response         │
│ • JSON conversion          │
│ • Status code setting      │
│ • Header inclusion         │
└──────┬─────────────────────┘
       │
       │ 11. Middleware Response Handling
       ▼
┌────────────────────────────┐
│   Response Middleware      │
│ • Add security headers     │
│ • Add CORS headers         │
│ • Response compression     │
└──────┬─────────────────────┘
       │
       │ 12. Return to Client
       ▼
┌────────────────────────────┐
│   Client (Browser)         │
│ • Parse JSON response      │
│ • Update UI                │
│ • Handle errors            │
└────────────────────────────┘
```

---

## 4. Database Architecture

### Database Schema (Simplified)

```
┌──────────────────────────────┐
│         users table          │
├──────────────────────────────┤
│ id (PK)                      │
│ name                         │
│ email (UNIQUE)               │
│ hashed_password              │
│ role (admin/manager/worker)  │
│ phone                        │
│ created_at                   │
│ updated_at                   │
└──────────────────────────────┘
              │
              │ (1:M)
              ▼
┌──────────────────────────────┐
│   livestock_batches table    │
├──────────────────────────────┤
│ id (PK)                      │
│ user_id (FK)                 │
│ batch_name                   │
│ animal_type                  │
│ count                        │
│ acquisition_date             │
│ status                       │
│ location                     │
│ created_at                   │
└──────────────────────────────┘
              │
              │ (1:M)
              ▼
┌──────────────────────────────┐
│    animal_events table       │
├──────────────────────────────┤
│ id (PK)                      │
│ batch_id (FK)                │
│ event_type                   │
│ description                  │
│ date                         │
│ created_at                   │
└──────────────────────────────┘

┌──────────────────────────────┐
│    inventory_items table     │
├──────────────────────────────┤
│ id (PK)                      │
│ user_id (FK)                 │
│ item_name                    │
│ item_type                    │
│ quantity                     │
│ unit                         │
│ min_quantity                 │
│ max_quantity                 │
│ supplier_id (FK)             │
│ created_at                   │
└──────────────────────────────┘
              │
              │ (1:M)
              ▼
┌──────────────────────────────┐
│    transactions table        │
├──────────────────────────────┤
│ id (PK)                      │
│ inventory_id (FK)            │
│ type (purchase/sale/loss)    │
│ quantity                     │
│ date                         │
│ created_at                   │
└──────────────────────────────┘
```

### Key Relationships

```
users
  ├──→ livestock_batches (1:M) - User owns multiple batches
  ├──→ inventory_items (1:M)   - User manages inventory
  ├──→ tasks (1:M)             - User assigned tasks
  └──→ financial_transactions  - User records financial data

livestock_batches
  ├──→ animal_events (1:M)     - Events in batch history
  └──→ sensor_readings (1:M)   - Sensor data for batch

inventory_items
  ├──→ transactions (1:M)      - Transaction history
  └──→ inventory_transfers (1:M)
```

---

## 5. Authentication & Security Architecture

### Authentication Flow

```
┌─────────────────┐
│   User Login    │
│ email/password  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│ Validate Credentials        │
│ • Check email exists        │
│ • Verify password (bcrypt)  │
└────────┬────────────────────┘
         │
    ┌────┴────┐
    NO       YES
    │         │
    ▼         ▼
  Error   ┌──────────────┐
          │ Generate JWT │
          │ (1hr expiry) │
          └────────┬─────┘
                   │
                   ▼
          ┌─────────────────┐
          │ Return Token    │
          │ + User Info     │
          └────────┬────────┘
                   │
      ┌────────────┴────────────┐
      │                         │
      ▼                         ▼
   Store in            Store in Backend
   Client              Session Store
   localStorage        (Redis)
      │                         │
      └────────────┬────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Include in Requests  │
        │ Authorization Header │
        │ Bearer <token>       │
        └────────────┬─────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  Verify Token        │
          │ • Signature valid?   │
          │ • Not expired?       │
          │ • Valid claims?      │
          └────────────┬─────────┘
                       │
                  ┌────┴────┐
                  OK        EXPIRED
                  │         │
                  ▼         ▼
              Allow    Refresh or
             Request   Re-login
```

### Security Layers

```
Layer 1: Transport Security
├── HTTPS/TLS encryption
├── HSTS header
└── Certificate pinning (mobile)

Layer 2: API Security
├── API Key validation
├── Rate limiting
├── CORS configuration
└── Request logging

Layer 3: Authentication
├── JWT token validation
├── Token expiration
├── Session management
└── Token refresh

Layer 4: Authorization
├── Role-based access (RBAC)
├── Resource-level permissions
├── Data isolation (multi-tenant)
└── Audit logging

Layer 5: Input Security
├── Input validation
├── SQL injection prevention
├── XSS prevention
├── CSRF protection
└── File upload security

Layer 6: Data Security
├── Password hashing (bcrypt)
├── Sensitive data encryption
├── Database access controls
└── Backup encryption
```

---

## 6. Deployment Architecture

### Development Environment

```
Local Machine
│
├── Frontend (PHP)
│   └── http://localhost/farmos
│
├── Backend (FastAPI)
│   └── http://localhost:8000
│
├── Database (MySQL)
│   └── localhost:3306
│
└── Cache (Redis optional)
    └── localhost:6379
```

### Staging Environment

```
Staging Server
│
├── Nginx (Reverse Proxy)
│   ├── HTTP → HTTPS redirect
│   └── Load balancer
│
├── Docker Container (FastAPI)
│   ├── Python 3.10
│   ├── uvicorn server
│   └── Mounted volumes
│
├── MySQL (Managed Service)
│   ├── Automated backups
│   ├── Replication
│   └── Multi-AZ
│
├── Redis (Cache Layer)
│   └── Session storage
│
└── Monitoring
    ├── Logs (ELK or CloudWatch)
    ├── Metrics (Prometheus)
    └── Alerts (PagerDuty)
```

### Production Environment

```
Production Infrastructure
│
├── CDN (CloudFront, CloudFlare)
│   └── Static assets
│
├── Load Balancer (AWS ELB)
│   ├── SSL/TLS termination
│   └── Health checks
│
├── Auto-Scaling Group
│   ├── Container 1 (FastAPI)
│   ├── Container 2 (FastAPI)
│   ├── Container 3 (FastAPI)
│   └── Auto-scale 2-10
│
├── Database Cluster
│   ├── Primary MySQL (RDS)
│   ├── Read Replicas (2)
│   ├── Automated backups
│   └── Point-in-time recovery
│
├── Cache Cluster
│   ├── Redis Primary
│   └── Redis Backup
│
├── Message Queue (Future)
│   └── Background jobs
│
└── Monitoring Stack
    ├── CloudWatch/DataDog
    ├── ELK Stack
    ├── Prometheus/Grafana
    └── PagerDuty Alerts
```

---

## 7. Security Architecture

### Network Security

```
┌─────────────────────────────────────────┐
│   Internet / External Users             │
└────────────────┬────────────────────────┘
                 │
    ┌────────────▼──────────────┐
    │   DDoS Protection         │
    │   (CloudFlare/AWS Shield) │
    └────────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │   Web Application         │
    │   Firewall (WAF)          │
    │   (Block malicious)       │
    └────────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │   HTTPS/TLS               │
    │   • Encryption            │
    │   • Certificate           │
    │   • HSTS headers          │
    └────────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │   API Gateway             │
    │   • Rate limiting         │
    │   • Request validation    │
    │   • API key checking      │
    └────────────┬──────────────┘
                 │
                 ▼
    ┌────────────────────────────┐
    │   Private Subnet           │
    │   (FastAPI Containers)     │
    │   • Security groups        │
    │   • Network policies       │
    │   • Internal IPs only      │
    └────────────┬───────────────┘
                 │
           ┌─────┴──────┐
           │            │
    ┌──────▼─────┐  ┌────▼──────┐
    │ Database   │  │ Cache     │
    │ (RDS)      │  │ (Redis)   │
    │            │  │           │
    │ Encrypted  │  │ Encrypted │
    │ Backups    │  │ Access    │
    │ Audit logs │  │ Control   │
    └────────────┘  └───────────┘
```

---

## 8. Scalability Architecture

### Horizontal Scaling

```
User Traffic
    ↓
┌─────────────────────────────┐
│  Load Balancer (AWS ALB)    │
│  • Distributes traffic      │
│  • Health checks            │
│  • SSL termination          │
└────────────┬────────────────┘
             │
    ┌────────┼────────┐
    │        │        │
    ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐
│App 1 │ │App 2 │ │App 3 │  ← Stateless Containers
│      │ │      │ │      │     (Can spawn more)
└──┬───┘ └──┬───┘ └──┬───┘
   │        │        │
   └────────┬────────┘
            │
      ┌─────▼─────┐
      │   Redis   │
      │  Cluster  │  ← Shared Session Store
      │           │
      └─────┬─────┘
            │
      ┌─────▼─────────────┐
      │ MySQL Primary DB  │
      │ + 2 Read Replicas │
      │ + Backups         │
      └───────────────────┘
```

### Database Scaling

```
Write Operations → Primary Database
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
    ▼                  ▼                  ▼
Read Replica 1   Read Replica 2   Read Replica 3

Application Load
├── Writes (5%) → Primary
└── Reads (95%)  → Replicas (Round-robin)

Benefits:
• Write throughput limited only by primary
• Read throughput scales horizontally
• High availability with failover
```

---

## 9. Monitoring & Observability Architecture

```
┌─────────────────────────────────────┐
│   Application (FastAPI)             │
│ • Structured logging                │
│ • Prometheus metrics                │
│ • Distributed tracing               │
└────────┬────────────────────────────┘
         │
    ┌────┼────────────────────┐
    │    │                    │
    ▼    ▼                    ▼
┌──────────────┐   ┌──────────────┐   ┌────────────┐
│ Log Collector │   │ Metrics       │   │ Traces     │
│ (Fluentd)     │   │ (Prometheus)  │   │ (Jaeger)   │
└──────┬───────┘   └────────┬──────┘   └─────┬──────┘
       │                    │               │
       ▼                    ▼               ▼
   ┌─────────────────┐  ┌─────────────────┐
   │ ELK Stack       │  │ Grafana         │
   │ (Elasticsearch) │  │ Dashboards      │
   │ (Kibana)        │  │ & Alerts        │
   └────────┬────────┘  └─────────────────┘
            │
            ▼
   ┌─────────────────┐
   │ Alert Manager   │
   │ • PagerDuty     │
   │ • Slack         │
   │ • Email         │
   └─────────────────┘
```

---

## 10. Module Interaction Diagram

```
┌──────────────────────────────────────┐
│        API Router Layer              │
│ /api/auth /api/livestock /api/iot... │
└────────────────┬─────────────────────┘
                 │
    ┌────────────▼────────────┐
    │   Authentication        │
    │   & Authorization       │
    │   (security.py)         │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Input Validation      │
    │   (validation.py)       │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Business Logic        │
    │   (Handler functions)   │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Data Access           │
    │   (SQLAlchemy ORM)      │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Error Handling        │
    │   (errors.py)           │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Logging               │
    │   (logging_config.py)   │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │   Response Building     │
    │   (JSON serialization)  │
    └────────────────────────┘
```

---

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Web Server** | Nginx | 1.24+ |
| **Application Server** | FastAPI | 0.104+ |
| **Python** | Python | 3.10+ |
| **Database** | MySQL | 5.7+ or 8.0+ |
| **ORM** | SQLAlchemy | 2.0+ |
| **Cache** | Redis | 6.0+ |
| **Authentication** | JWT | PyJWT 2.8+ |
| **Password Hashing** | bcrypt | 4.1+ |
| **Logging** | structlog | 23.2+ |
| **Testing** | pytest | 7.4+ |
| **Code Quality** | Black, Pylint, mypy | Latest |
| **Monitoring** | Prometheus, ELK | Latest |

---

## Design Patterns Used

| Pattern | Usage | Benefit |
|---------|-------|---------|
| **MVC** | Routers → Logic → DB | Separation of concerns |
| **Dependency Injection** | FastAPI `Depends()` | Testability, reusability |
| **Middleware** | Rate limiting, logging | Cross-cutting concerns |
| **Repository** | Data access layer | Data access abstraction |
| **Factory** | Object creation | Flexible instantiation |
| **Singleton** | Database connection | Resource efficiency |
| **Strategy** | Validation, logging | Flexible algorithms |

---

## Performance Considerations

### Response Time Targets

- API endpoints: < 200ms p95, < 500ms p99
- Database queries: < 100ms p95
- Authentication: < 50ms p95

### Optimization Strategies

1. **Database**: Indexes, query optimization, connection pooling
2. **Caching**: Redis for sessions, query results
3. **API**: Pagination, filtering, field selection
4. **Code**: Async operations, batch processing
5. **Infrastructure**: Auto-scaling, load balancing, CDN

---

## Security Best Practices

✅ Defense in depth (multiple layers)  
✅ Principle of least privilege  
✅ Secure by default  
✅ Regular security audits  
✅ Dependency scanning  
✅ Secret management  
✅ Encryption at rest & in transit  
✅ Comprehensive logging  
✅ Incident response plan  

---

**Document Version**: 1.0  
**Last Updated**: March 12, 2026  
**Status**: Complete ✅
