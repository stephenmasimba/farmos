# FarmOS - System Analysis: Issues and Improvements

**Date**: April 8, 2026  
**Version**: 1.1  
**Status**: Updated After Runtime Path Standardization

---

## 📊 Executive Summary

FarmOS is a feature-rich farm management system with a pure PHP backend and PHP frontend. The system has strong foundational architecture but requires improvements in security, code quality, testing, and documentation. This document identifies critical issues, medium-priority improvements, and low-priority enhancements.

Recent updates (April 2026): runtime paths were standardized under `app/`, legacy Python startup paths were removed, and startup/test scripts were aligned to the PHP/WAMP flow.

---

## 🔴 CRITICAL ISSUES (Must Fix)

### 1. **Security Vulnerabilities**

#### 1.1 Hardcoded Secrets
- **Issue**: JWT secret must not fall back to insecure defaults (and must be explicitly set in production)
- **Risk**: HIGH - Anyone can decode JWTs and spoof API access
- **Impact**: Complete authentication bypass possible
- **File**: `app/backend/config/env.php`, `app/backend/src/Security.php`
- **Fix Priority**: CRITICAL
- **Solution**:
  - Require `JWT_SECRET` in production/staging and reject missing/weak values at startup.
  - Allow dev-only generation into `app/backend/config/.env` (writable environments only).

#### 1.2 Input Validation Coverage Gaps
- **Issue**: Some endpoints may still accept user input without full validation
- **Risk**: HIGH - SQL Injection, XSS, NoSQL Injection possible
- **File**: `app/backend/src/Controllers/*`
- **Fix Priority**: CRITICAL
- **Solution**: Validate all request bodies and query params via `app/backend/src/Validation.php`.

#### 1.3 Rate Limiting Coverage Gaps
- **Issue**: Authentication endpoints must remain consistently rate limited
- **Risk**: HIGH - Brute force attacks on login
- **File**: `app/backend/src/RateLimiter.php`, `app/backend/public/index.php`
- **Fix Priority**: CRITICAL
- **Solution**: Implement rate limiting with an in-memory store (or Redis if you add it later)

#### 1.4 CORS Configuration Issues
- **Issue**: CORS origin is configurable but defaults to localhost only
- **Risk**: MEDIUM - Potential for CORS bypass if misconfigured in production
- **File**: `app/backend/public/index.php`
- **Fix Priority**: HIGH
- **Solution**: Validate `CORS_ORIGIN` for production and avoid wildcard origins.

#### 1.5 No HTTPS/TLS Configuration
- **Issue**: No HTTPS enforcement or TLS setup at the reverse proxy/web server
- **Risk**: HIGH - All communications transmitted in plain text in production
- **File**: All network communications
- **Fix Priority**: CRITICAL
- **Solution**: Add HTTPS redirect, SSL/TLS certificates, security headers

#### 1.6 Authentication Enforcement Gaps
- **Issue**: Some protected routes may not validate authentication consistently
- **Risk**: HIGH - Unauthorized access to sensitive operations
- **File**: `app/backend/public/index.php`, `app/backend/src/Middleware/*`
- **Fix Priority**: CRITICAL
- **Solution**: Enforce JWT auth middleware for all protected routes.

#### 1.7 No CSRF Protection
- **Issue**: CSRF protection is required for cookie-based auth or state-changing form posts.
- **Risk**: HIGH - Cross-site request forgery attacks possible (when browser automatically sends credentials)
- **File**: PHP frontend forms / endpoints that mutate state via cookies
- **Fix Priority**: HIGH
- **Solution**:
  - Generate unique CSRF tokens per session
  - Validate tokens on all state-changing requests
  - Store in session

#### 1.8 Password Storage Concerns
- **Issue**: Password hashing implementation not verified
- **Risk**: MEDIUM - Weak password hashing vulnerable to attacks
- **File**: `app/backend/src/Auth.php`
- **Fix Priority**: HIGH
- **Requirement**: 
  - Use bcrypt with appropriate cost factor (10-12)
  - Never log passwords
  - Implement password complexity requirements

#### 1.9 Missing SQL Injection Protection
- **Issue**: Avoid direct database access from the PHP frontend; if needed, always use prepared statements.
- **Risk**: CRITICAL - Direct database access is vulnerable without strict parameterization
- **File**: Any PHP frontend code that runs SQL directly
- **Fix Priority**: CRITICAL
- **Solution**: Use prepared statements everywhere (or route all data access via the API)

#### 1.10 No API Key Rotation Mechanism
- **Issue**: If API keys are introduced, they must be rotatable and revocable
- **Risk**: HIGH - Compromised keys cannot be quickly deactivated
- **Fix Priority**: HIGH
- **Solution**: Store API keys in the database with creation/expiration dates and audit logs.

---

### 2. **Critical Dependency Issues**

#### 2.1 Dependency Reproducibility Risks
- **Issue**: Dependency manifests must remain complete and reproducible
- **File**: `app/backend/composer.json`, `app/backend/composer.lock`
- **Fix Priority**: CRITICAL
- **Solution**: Use Composer for dependency management and lock versions via `composer.lock`.

#### 2.2 No Version Pinning
- **Issue**: Dependencies must be pinned for reproducible builds
- **Risk**: MEDIUM - Dependency conflicts in production
- **Solution**: Commit `composer.lock` and install using `composer install`.

---

### 3. **Database Issues**

#### 3.1 No Database Migrations Strategy
- **Issue**: Schema changes made directly, no version control for migrations
- **Risk**: CRITICAL - Cannot rollback changes, difficult to replicate environments
- **File**: Database schema and deployment scripts
- **Fix Priority**: CRITICAL
- **Solution**: Track schema via `app/database/schema.sql` and apply incremental SQL migrations with a `schema_migrations` table.

#### 3.2 Missing Foreign Key Constraints
- **Issue**: Relationships between tables not enforced at database level
- **Risk**: HIGH - Data integrity issues possible
- **File**: Database schema
- **Fix Priority**: HIGH
- **Solution**: Add foreign key constraints for all relationships

#### 3.3 No Backup Strategy Documentation
- **Issue**: No backup procedures or automated backups configured
- **Risk**: CRITICAL - Data loss on database failure
- **File**: Missing entirely
- **Fix Priority**: CRITICAL
- **Solution**: Implement automated daily backups with retention policy

#### 3.4 Missing Data Encryption
- **Issue**: Sensitive data (passwords, payment info) stored in plain text
- **Risk**: CRITICAL - Confidentiality breach if database compromised
- **File**: All database tables
- **Fix Priority**: CRITICAL
- **Solution**: Encrypt sensitive fields with encryption library

---

### 4. **Code Quality Issues**

#### 4.1 No Error Handling Standards
- **Issue**: Keep error responses consistent across all API endpoints
- **Risk**: MEDIUM - Difficult to debug, bad UX
- **File**: All routers
- **Fix Priority**: HIGH
- **Solution**: Use a standardized error response format (already provided by `app/backend/src/Response.php`)
  ```json
  {
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "User-friendly message",
      "details": {}
    }
  }
  ```

#### 4.2 No Logging Framework
- **Issue**: Logging must be structured and written to a writable location in production
- **Risk**: MEDIUM - Difficult to debug production issues
- **File**: `app/backend/src/Logger.php`, `app/backend/config/env.php`
- **Fix Priority**: HIGH
- **Solution**: Use centralized JSON logging with configurable log levels and rotation

#### 4.3 Environment Variable Validation Gaps
- **Issue**: Environment variables may not be validated comprehensively on startup
- **Risk**: MEDIUM - Missing configuration causes runtime errors
- **File**: `app/backend/config/env.php`
- **Fix Priority**: MEDIUM
- **Solution**: Create startup validation function checking all required env vars

#### 4.4 No Type Hints in Some Modules
- **Issue**: Not all files have complete type annotations
- **Risk**: LOW - Reduced IDE support and harder maintenance
- **File**: Legacy modules
- **Fix Priority**: MEDIUM
- **Solution**: Enforce static analysis in CI/CD (PHPStan) and add strict types where appropriate

---

### 5. **Testing Issues**

#### 5.1 Minimal Test Coverage
- **Issue**: Keep expanding unit + feature test coverage
- **Risk**: HIGH - Regressions not caught before production
- **File**: `app/backend/tests/`
- **Fix Priority**: CRITICAL
- **Solution**: 
  - Target 80%+ code coverage
  - Unit tests for all functions
  - Integration tests for API endpoints
  - Use PHPUnit with shared test helpers

#### 5.2 No Test Database Configuration
- **Issue**: Tests must never run against production data
- **Risk**: CRITICAL - Data corruption in production
- **File**: `app/backend/tests/ApiTestCase.php`
- **Fix Priority**: CRITICAL
- **Solution**: Use an isolated test database created/dropped by the test suite

#### 5.3 No Performance/Load Testing
- **Issue**: No load testing defined or configured
- **Risk**: MEDIUM - Unknown capacity limits
- **File**: Missing entirely
- **Fix Priority**: MEDIUM
- **Solution**: Create load tests with ApacheBench (`ab`) or k6

---

### 6. **API Design Issues**

#### 6.1 Inconsistent Endpoint Naming
- **Issue**: Endpoints may not follow REST conventions consistently
- **Risk**: MEDIUM - Confusing API, hard to document
- **File**: Multiple routers
- **Fix Priority**: MEDIUM
- **Solution**: Enforce REST conventions:
  - `GET /resources` - List
  - `POST /resources` - Create
  - `GET /resources/{id}` - Get one
  - `PUT /resources/{id}` - Update
  - `DELETE /resources/{id}` - Delete

#### 6.2 No API Versioning
- **Issue**: API versioning is not currently enforced
- **Risk**: MEDIUM - Breaking changes confuse clients
- **File**: `app/backend/public/index.php`
- **Fix Priority**: MEDIUM
- **Solution**: Add `/api/v1/...` route prefix (simplest), or enforce an `Accept` vendor media type header

#### 6.3 No Request/Response Compression
- **Issue**: Large responses not compressed
- **Risk**: LOW - Slower performance
- **File**: All endpoints
- **Fix Priority**: LOW
- **Solution**: Add gzip compression middleware

#### 6.4 Missing API Documentation Standards
- **Issue**: Not all endpoints have detailed OpenAPI documentation
- **Risk**: MEDIUM - Developers can't use API effectively
- **File**: Multiple routers
- **Fix Priority**: MEDIUM
- **Solution**: Add docstrings with examples to all endpoints

---

---

## 🟡 MEDIUM-PRIORITY IMPROVEMENTS

### 1. **Architecture and Code Organization**

#### 1.1 Router Organization
- **Issue**: Routing can become too large if all endpoints live in a single file.
- **Improvement**: Keep routing thin and move logic into controllers/services.
- **Solution**: Keep this structure (already present in `app/backend/src/`):
  ```
  app/backend/
    public/index.php
    src/
      Controllers/
      Models/
      Services/
      Repositories/
      Middleware/
  ```

#### 1.2 Service Layer Missing
- **Issue**: Business logic can drift into controllers/routes.
- **Improvement**: Separate concerns with a service layer.
- **Solution**: Use the existing `app/backend/src/Services/` and keep controllers thin.

#### 1.3 Repository Pattern Missing
- **Issue**: Database access can get duplicated across controllers.
- **Improvement**: Centralize with a repository pattern.
- **Solution**: Use the existing `app/backend/src/Repositories/` for shared queries.

#### 1.4 Configuration Management
- **Issue**: Configuration hardcoded or in multiple places
- **Improvement**: Centralized configuration
- **Solution**: Use `app/backend/config/env.php` + `app/backend/config/.env` (not committed).

---

### 2. **Frontend Issues**

#### 2.1 PHP Architecture
- **Issue**: Mixed concerns in PHP files
- **Improvement**: Implement proper MVC separation
- **Solution**: 
  - Keep templates/components focused on rendering
  - Keep API calls and business logic in shared helpers (e.g. `lib/`)
  - Avoid direct SQL from frontend pages; use the API as the data boundary

#### 2.2 Frontend Authentication
- **Issue**: Session handling may have security gaps
- **Improvement**: Implement secure session management
- **Solution**:
  - Session timeout (30 minutes)
  - Regenerate session ID on login
  - Secure cookies (HttpOnly, Secure flags)

#### 2.3 Frontend Form Validation
- **Issue**: All validation on backend, no client-side validation
- **Improvement**: Add client-side validation for UX
- **Solution**: Use HTML5 validation + JavaScript validation

#### 2.4 Frontend Error Handling
- **Issue**: Error messages may not be user-friendly
- **Improvement**: Implement user-friendly error handling
- **Solution**: Create error handling utilities

#### 2.5 Frontend Code Duplication
- **Issue**: Repeated code in templates and components
- **Improvement**: Better component reuse
- **Solution**: Create PHP component library

---

### 3. **Database Improvements**

#### 3.1 Query Performance
- **Issue**: No indexes documented for common queries
- **Improvement**: Optimize database queries
- **Solution**:
  - Add EXPLAIN analysis for slow queries
  - Create composite indexes for joins
  - Document query optimization

#### 3.2 Connection Pooling
- **Issue**: Database connections may not be pooled
- **Improvement**: Implement connection pooling
- **Solution**: Use persistent connections and tune the MySQL server and PHP-FPM/web server pools

#### 3.3 Data Archival Strategy
- **Issue**: No strategy for old data removal
- **Improvement**: Archive historical data
- **Solution**: Implement data retention policies and archival process

---

### 4. **Monitoring and Observability**

#### 4.1 No Centralized Logging
- **Issue**: Logs scattered across files
- **Improvement**: Centralized logging with ELK or similar
- **Solution**: Implement structured logging to a writable directory (e.g. `app/backend/storage/logs`) and/or web server error logs

#### 4.2 No Metrics Collection
- **Issue**: No performance metrics tracked
- **Improvement**: Collect and monitor metrics
- **Solution**: Integrate Prometheus metrics

#### 4.3 Health Check Depth Is Limited
- **Issue**: Basic health checks exist but are incomplete
- **Improvement**: Detailed health checks
- **Solution**: 
  - Database connectivity check
  - Cache connectivity check
  - External service checks

#### 4.4 No Error Tracking
- **Issue**: No centralized error tracking
- **Improvement**: Implement error tracking
- **Solution**: Integrate Sentry or similar

---

### 5. **Documentation Improvements**

#### 5.1 API Documentation
- **Issue**: OpenAPI docs incomplete for some endpoints
- **Improvement**: Complete API documentation
- **Solution**: 
  - Add examples for all endpoints
  - Document all response codes
  - Document request/response body examples
  - Add authentication requirements

#### 5.2 Database Documentation
- **Issue**: Schema not documented
- **Improvement**: Document database schema
- **Solution**:
  - Create schema diagram
  - Document all table relationships
  - Add column descriptions

#### 5.3 Architecture Documentation
- **Issue**: Overall architecture not fully documented
- **Improvement**: Create architecture documentation
- **Solution**:
  - Data flow diagrams
  - Deployment diagrams
  - Component interaction diagrams

#### 5.4 Code Comments
- **Issue**: Complex logic lacks comments
- **Improvement**: Add explanatory comments
- **Solution**: Document "why" not just "what"

---

### 6. **DevOps and Deployment**

#### 6.1 Deployment Standardization Gaps
- **Issue**: Shared-hosting deployment must remain standardized and repeatable
- **Improvement**: Document shared hosting deployment setup (no container requirement)
- **Solution**:
  - Document web root (`app/backend/public/`)
  - Document environment file (`app/backend/config/.env`)
  - Document schema import (`app/database/schema.sql`)

#### 6.2 No CI/CD Pipeline
- **Issue**: No automated testing or deployment
- **Improvement**: Implement CI/CD
- **Solution**:
  - GitHub Actions or GitLab CI
  - Automated testing on push
  - Automated linting and type checking
  - Automated deployment to staging

#### 6.3 No Environment Management
- **Issue**: Configuration scattered
- **Improvement**: Proper environment management
- **Solution**:
  - `.env.example` file
  - Separate configs for dev/staging/production
  - Environment-specific database URLs

#### 6.4 No Secrets Management
- **Issue**: Secrets in code/files
- **Improvement**: Implement secrets management
- **Solution**:
  - Use environment variables
  - Never commit secrets
  - Use secrets vault in production (AWS Secrets Manager, etc.)

---

### 7. **Performance Optimization**

#### 7.1 No Caching Strategy
- **Issue**: No caching mentioned/implemented
- **Improvement**: Implement caching
- **Solution**:
  - Redis for session/data caching
  - HTTP caching headers for frontend
  - Query result caching

#### 7.2 API Response Time
- **Issue**: No documented response time targets
- **Improvement**: Define and monitor SLAs
- **Solution**:
  - P95 response time < 200ms
  - P99 response time < 500ms
  - Track metrics continuously

#### 7.3 Database Query Optimization
- **Issue**: No N+1 query prevention
- **Improvement**: Optimize queries
- **Solution**:
  - Use JOINs and select only required columns
  - Batch similar queries
  - Use query pagination

---

### 8. **Feature Completeness**

#### 8.1 Email Notifications
- **Issue**: May not be fully implemented
- **Improvement**: Complete email integration
- **Solution**:
  - SMTP configuration
  - Email templates
  - Queue for async sending

#### 8.2 File Upload Handling
- **Issue**: No file upload validation mentioned
- **Improvement**: Secure file uploads
- **Solution**:
  - File type validation
  - File size limits
  - Scan for malware
  - Store in secure location

#### 8.3 Data Export Functionality
- **Issue**: No export features documented
- **Improvement**: Allow data export
- **Solution**:
  - CSV export
  - PDF reports
  - Excel export with formatting

#### 8.4 Audit Trail
- **Issue**: May lack comprehensive audit logging
- **Improvement**: Implement full audit trail
- **Solution**:
  - Track all changes to important data
  - Store who, what, when, why
  - Make audit logs immutable

---

---

## 🟢 LOW-PRIORITY ENHANCEMENTS

### 1. **User Experience**

#### 1.1 Responsive Design
- **Issue**: Frontend may not be fully responsive
- **Enhancement**: Ensure mobile-first responsive design
- **Solution**: Use Bootstrap or Tailwind CSS consistently

#### 1.2 Dark Mode Support
- **Enhancement**: Add dark mode theme
- **Solution**: CSS variables and theme switcher

#### 1.3 Accessibility (a11y)
- **Enhancement**: Improve accessibility compliance
- **Solution**:
  - WCAG 2.1 AA compliance
  - Keyboard navigation
  - Screen reader support

#### 1.4 Internationalization (i18n)
- **Status**: System appears to have i18n setup
- **Enhancement**: Complete and test all languages
- **Solution**: Verify all strings translated

#### 1.5 Notifications and Alerts
- **Enhancement**: Real-time notifications
- **Solution**: WebSocket for live updates

---

### 2. **Advanced Features**

#### 2.1 Data Visualization
- **Enhancement**: Add charts and graphs
- **Solution**: Integrate Chart.js or D3.js

#### 2.2 Reporting Engine
- **Enhancement**: Templated report generation
- **Solution**: Build custom report builder

#### 2.3 Mobile App
- **Enhancement**: Native mobile applications
- **Solution**: React Native or Flutter apps

#### 2.4 Third-party Integration
- **Enhancement**: Integrate with external services
- **Solution**:
  - Weather API integration
  - Payment gateway integration
  - Cloud storage integration

---

### 3. **Code Quality**

#### 3.1 Code Formatting
- **Enhancement**: Consistent code style
- **Solution**:
  - PHP: PHPCS (PSR-12)
  - Pre-commit hooks

#### 3.2 Linting
- **Enhancement**: Catch code issues automatically
- **Solution**:
  - PHP: PHPStan
  - JavaScript: ESLint

#### 3.3 Static Analysis
- **Enhancement**: Find potential bugs
- **Solution**:
  - SAST tools (SonarQube)
  - Dependency scanning (Snyk)
  - Secret scanning (GitGuardian)

---

### 4. **Scalability**

#### 4.1 Horizontal Scaling
- **Enhancement**: Support multiple backend instances
- **Solution**:
  - Load balancer (Nginx)
  - Session store (Redis)
  - Database replication

#### 4.2 Caching Strategy
- **Enhancement**: Multi-layer caching
- **Solution**:
  - Application-level caching
  - Database query caching
  - CDN for static assets

#### 4.3 Async Processing
- **Enhancement**: Background job queue
- **Solution**:
  - Queue worker (Redis-backed) for background tasks
  - Scheduled jobs via OS scheduler or a cron-like runner

---

### 5. **Compliance and Security Hardening**

#### 5.1 GDPR Compliance
- **Enhancement**: Data privacy features
- **Solution**:
  - Right to be forgotten
  - Data export functionality
  - Privacy policy page

#### 5.2 HIPAA Compliance (if needed)
- **Enhancement**: Health data handling
- **Solution**:
  - Encryption at rest and in transit
  - Access controls
  - Audit logging

#### 5.3 PCI DSS Compliance
- **Enhancement**: Payment security
- **Solution**:
  - Use payment gateway (don't store cards)
  - Encryption for sensitive data
  - Regular security testing

#### 5.4 Security Headers
- **Enhancement**: Add HTTP security headers
- **Solution**:
  ```text
  Content-Security-Policy
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Strict-Transport-Security
  Referrer-Policy
  Permissions-Policy
  ```

---

---

## 📋 Implementation Roadmap

### Phase 1: Critical Security (Weeks 1-2)
- [x] Fix hardcoded secrets (require `JWT_SECRET` in production/staging)
- [x] Implement input validation on core endpoints
- [x] Add rate limiting to auth endpoints
- [ ] Implement CSRF protection where cookie-based state changes exist
- [x] Add SQL injection protection via prepared statements in the backend DB layer

### Phase 2: Testing Infrastructure (Weeks 3-4)
- [x] Set up isolated test database
- [ ] Write unit tests (target 80%+ coverage)
- [x] Create integration/feature tests for API endpoints
- [ ] Set up CI/CD pipeline
- [ ] Add automated testing on commit

### Phase 3: Code Quality (Weeks 5-6)
- [x] Implement logging framework
- [x] Add error handling standards
- [x] Refactor into service/repository layers
- [x] Add type checking with PHPStan
- [x] Set up code formatting with PHPCBF

### Phase 4: Infrastructure (Weeks 7-8)
- [ ] Set up environment management
- [ ] Implement backup procedures
- [ ] Set up monitoring (metrics, logs)
- [ ] Document shared hosting deployment steps

### Phase 5: Documentation (Weeks 9-10)
- [ ] Complete API documentation
- [ ] Create architecture diagrams
- [ ] Write deployment guide
- [ ] Document database schema
- [ ] Create troubleshooting guide

### Phase 6: Performance & Scale (Weeks 11-12)
- [ ] Implement caching strategy
- [ ] Optimize database queries
- [ ] Set up connection pooling
- [ ] Load testing
- [ ] Performance optimization

---

## 📊 Risk Assessment

### Critical Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|-----------|
| Security breach from hardcoded secrets | CRITICAL | HIGH | Rotate secrets immediately, use environment variables |
| SQL injection in frontend | CRITICAL | MEDIUM | Add prepared statements, input validation |
| Data loss (no backups) | CRITICAL | MEDIUM | Implement automated backups |
| Unauthorized access | HIGH | MEDIUM | Add comprehensive auth to all routes |
| Performance degradation | HIGH | MEDIUM | Implement caching and optimize queries |

### Medium Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|-----------|
| Dependency conflicts | MEDIUM | MEDIUM | Pin all versions, use lockfile |
| Compatibility issues | MEDIUM | LOW | Comprehensive integration testing |
| User confusion (poor docs) | MEDIUM | MEDIUM | Improve documentation |

---

## 💡 Quick Wins (High Value, Low Effort)

1. **Use Composer lockfile** (30 min)
   - Pin all dependencies with `composer.lock`
   - Huge improvement in deployability

2. **Create .env.example file** (15 min)
   - Template for configuration
   - Reduces setup errors

3. **Add logging throughout codebase** (4 hours)
   - Use structured JSON logging
   - Easy debugging in production

4. **Standardize error responses** (2 hours)
   - Create unified error format
   - Better API consistency

5. **Add database backup script** (1 hour)
   - MySQL dump script
   - Prevents catastrophic data loss

6. **Create basic unit tests** (8 hours)
   - Start with critical functions
   - Foundation for TDD

7. **Add API documentation examples** (4 hours)
   - For all major endpoints
   - Improves usability

---

## 📞 Next Steps

1. **Create a GitHub/GitLab issue** for each critical item
2. **Schedule security review** with team
3. **Assign priorities** based on business needs
4. **Create sprint plan** for Phase 1
5. **Set up CI/CD** early for quick feedback

---

## 📝 Notes

- This analysis is based on code review of the current system
- Actual issues may differ after running the application
- Some issues may require different solutions based on specific use cases
- Regular security audits recommended (quarterly minimum)
- Runtime and documentation now use `app/` as the primary project path.
- If `begin_pyphp/backend` still appears on a machine, it is a legacy locked-path cleanup item (typically held by a running web server process).

---

**Document prepared**: April 8, 2026  
**Review cycle**: Recommend quarterly updates to this analysis
