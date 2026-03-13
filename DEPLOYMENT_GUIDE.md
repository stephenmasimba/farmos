# FarmOS Deployment Guide

**Version**: 1.0.0  
**Updated**: March 12, 2026  
**Status**: Production Ready

---

## 📋 Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Development Setup](#development-setup)
3. [Staging Deployment](#staging-deployment)
4. [Production Deployment](#production-deployment)
5. [Post-Deployment Verification](#post-deployment-verification)
6. [Monitoring & Maintenance](#monitoring--maintenance)
7. [Rollback Procedures](#rollback-procedures)
8. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

### Code Quality
- [ ] Backend tests pass: `cd begin_pyphp/backend && composer run test`
- [ ] Lint passes: `cd begin_pyphp/backend && composer run lint`
- [ ] Static analysis passes: `cd begin_pyphp/backend && composer run type-check`

### Security
- [ ] No hardcoded secrets
- [ ] All env vars use defaults from `.env.example`
- [ ] `.env` file NOT in git
- [ ] `.gitignore` includes `.env`
- [ ] SSL/TLS certificates ready
- [ ] Database credentials secured in vault
- [ ] API keys generated with sufficient entropy
- [ ] Security headers configured

### Documentation
- [ ] README.md updated
- [ ] API documentation current
- [ ] Deployment procedures documented
- [ ] Configuration documented
- [ ] Troubleshooting guide created

### Dependencies
- [ ] Composer dependencies locked (`composer.lock`)
- [ ] `begin_pyphp/backend/vendor/` not committed
- [ ] PHP extensions available (pdo, mbstring, curl, json)

### Database
- [ ] Migration scripts tested
- [ ] Backup procedures documented
- [ ] Restore procedures tested
- [ ] Performance baseline established
- [ ] Indexes created
- [ ] Query optimization completed

---

## Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourorg/farmos.git
cd farmos/begin_pyphp
```

### 2. Install Backend Dependencies

```bash
cd begin_pyphp/backend
composer install
```

### 3. Configure Environment

- Configure DB settings in `begin_pyphp/backend/config/env.php` (or create `begin_pyphp/backend/.env` from `.env.example`).
- Ensure MySQL is running and the target database exists.

### 4. Run Application

In development, run under WAMP/Apache:
- `http://localhost/farmos/begin_pyphp/backend/`

Or use the PHP built-in server:

```bash
cd begin_pyphp/backend
composer run serve
```

### 5. Run Tests

```bash
cd begin_pyphp/backend
composer run test
```

---

## Staging Deployment

### Prerequisites

- ✅ All pre-deployment checks passed
- ✅ Staging server available
- ✅ MySQL 5.7+ installed
- ✅ PHP 7.4+ installed
- ✅ Web server installed (Apache or Nginx + PHP-FPM)

### 1. Server Setup

```bash
# SSH to staging server
ssh deploy@staging.farmos.local

# Create application directory
sudo mkdir -p /srv/farmos
sudo chown deploy:deploy /srv/farmos

# Clone repository
cd /srv/farmos
git clone https://github.com/yourorg/farmos.git .
```

### 2. Install Backend Dependencies

```bash
cd /srv/farmos/begin_pyphp/backend
composer install --no-dev --optimize-autoloader
```

### 3. Environment Configuration

```bash
# Copy environment template
cp .env.example config/.env

# Edit with staging values
nano config/.env

# Configure DB settings in config/env.php or .env
# Ensure JWT_SECRET is set to a strong value
```

### 4. Database Setup

```bash
# Create database user
mysql -u root -p << EOF
CREATE DATABASE farmos_staging;
CREATE USER 'farmos_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON farmos_staging.* TO 'farmos_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Create tables (apply schema)
mysql -u farmos_user -p farmos_staging < /srv/farmos/begin_pyphp/database/schema.sql

# Verify tables
mysql -u farmos_user -p farmos_staging -e "SHOW TABLES;"
```

### 5. Nginx Configuration

Create `/etc/nginx/sites-available/farmos`:

```nginx
server {
    listen 80;
    server_name staging.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name staging.yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/staging.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/staging.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Compression
    gzip on;
    gzip_types application/json;
    gzip_min_length 1024;
    
    # Backend API (PHP)
    location /api/ {
        root /srv/farmos/begin_pyphp/backend/public;
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /health {
        root /srv/farmos/begin_pyphp/backend/public;
        try_files $uri /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
    
    # Frontend
    location / {
        root /srv/farmos/begin_pyphp/frontend/public;
        try_files $uri $uri/ /index.php?$query_string;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/farmos /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6. Services

Ensure your services are enabled and running:

```bash
sudo systemctl enable nginx
sudo systemctl restart nginx

sudo systemctl enable php-fpm
sudo systemctl restart php-fpm
```

### 7. Test Deployment

```bash
# Test API health
curl -k https://staging.yourdomain.com/health

# Test login
curl -k -X POST https://staging.yourdomain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"AdminPass123!"}'

# Check logs
tail -f /var/log/farmos/farmos.log
```

---

## Production Deployment

### Prerequisites

- ✅ All staging tests passed
- ✅ Load testing completed
- ✅ Security audit passed
- ✅ Disaster recovery plan in place
- ✅ Monitoring configured
- ✅ Backup procedures tested

### 1. Infrastructure Setup

**Database** (AWS RDS recommended):
```bash
# Create MySQL instance
aws rds create-db-instance \
  --db-instance-identifier farmos-prod \
  --db-instance-class db.t3.small \
  --engine mysql \
  --engine-version 8.0.28 \
  --master-username admin \
  --master-user-password <secure-password> \
  --allocated-storage 100 \
  --storage-type gp2 \
  --backup-retention-period 30
```

**Cache** (AWS ElastiCache recommended):
```bash
# Create Redis cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id farmos-cache \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --engine-version 6.x
```

**Load Balancer** (AWS ALB recommended):
- Set up SSL/TLS termination
- Configure health checks
- Set up auto-scaling group

### 2. Shared Hosting (Afrihost)

- Set the web root / document root to `begin_pyphp/backend/public/`.
- Create `begin_pyphp/backend/config/.env` on the server (do not commit it).
- Provision a MySQL database/user in the hosting control panel and import `begin_pyphp/database/schema.sql`.
- If Composer is available on the server:
  - Run `composer install --no-dev --optimize-autoloader` inside `begin_pyphp/backend/`.
  - If Composer is not available, install dependencies locally and upload `vendor/`.

### 3. Environment Configuration

```bash
# Production config/.env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.yourdomain.com

JWT_SECRET=<very-long-random-string-64-chars>

DATABASE_HOST=rds.amazonaws.com
DATABASE_PORT=3306
DATABASE_NAME=farmos
DB_USER=<db-user>
DB_PASSWORD=<db-password>
DATABASE_URL=mysql:host=rds.amazonaws.com;port=3306;dbname=farmos;charset=utf8mb4

CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com
LOG_LEVEL=info
LOG_FORMAT=json
LOG_DIR=/var/log/farmos
```

### 4. Database Migration

```bash
# Connect to production database
mysql -h production-db.amazonaws.com -u admin -p farmos

# Create tables (apply schema)
mysql -h production-db.amazonaws.com -u admin -p farmos < /srv/farmos/begin_pyphp/database/schema.sql
```

### 5. Deployment

```bash
# Using Kubernetes (recommended for scale)
kubectl create namespace farmos
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Or manual deployment
# SSH to prod server
ssh deploy@prod.farmos.local
cd /srv/farmos
git pull origin main
cd begin_pyphp/backend
composer install --no-dev --optimize-autoloader
sudo systemctl restart nginx
sudo systemctl restart php-fpm
```

### 6. Verification

```bash
# Check application health
curl -k https://api.yourdomain.com/health

# Check logs
ssh deploy@prod.farmos.local tail -f /var/log/farmos/farmos.log

# Run smoke tests
./scripts/smoke-tests.sh

# Check metrics
# Visit Grafana dashboard: https://monitoring.yourdomain.com
```

---

## Post-Deployment Verification

### 1. Health Checks

```bash
# Application health
curl https://api.yourdomain.com/health

# Database connectivity
curl https://api.yourdomain.com/api/auth/me \
  -H "Authorization: Bearer <token>"

# Cache connectivity
redis-cli -h cache.amazonaws.com PING

# SSL/TLS
openssl s_client -connect api.yourdomain.com:443
```

### 2. Performance Testing

```bash
# Response time
time curl https://api.yourdomain.com/health

# Load testing (example with ApacheBench)
ab -n 1000 -c 50 https://api.yourdomain.com/api/livestock

# Expected results:
# - p50: <100ms
# - p95: <200ms
# - p99: <500ms
```

### 3. Security Verification

```bash
# SSL/TLS check
nmap --script ssl-enum-ciphers -p 443 api.yourdomain.com

# Security headers
curl -I https://api.yourdomain.com/health
# Check for: HSTS, CSP, X-Frame-Options, etc.

# OWASP Top 10 verification
zap-baseline.py -t https://api.yourdomain.com
```

### 4. Backup Verification

```bash
# Test backup
./scripts/backup-database.sh

# Test restore
./scripts/restore-database.sh --from-backup latest

# Verify data integrity
mysql -u user -p farmos -e "SELECT COUNT(*) FROM users;"
```

---

## Monitoring & Maintenance

### Daily Tasks

- [ ] Check application health
- [ ] Review error logs
- [ ] Monitor resource usage (CPU, memory, disk)
- [ ] Verify backups completed

### Weekly Tasks

- [ ] Review security logs
- [ ] Check for dependency updates
- [ ] Verify disaster recovery procedures
- [ ] Review API metrics

### Monthly Tasks

- [ ] Update dependencies
- [ ] Security vulnerability scan
- [ ] Performance analysis
- [ ] Capacity planning

### Quarterly Tasks

- [ ] Full security audit
- [ ] Penetration testing
- [ ] Database optimization
- [ ] Disaster recovery drill

---

## Rollback Procedures

### Quick Rollback (Last 5 minutes)

```bash
# If using blue-green deployment
kubectl set image deployment/farmos-blue \
  farmos=your-registry/farmos:previous-version
```

### Database Rollback

```bash
# If migration failed, restore from backup
./scripts/restore-database.sh --from-backup latest

# Verify restore
mysql -u user -p farmos -e "SELECT COUNT(*) FROM users;"
```

### DNS Rollback

```bash
# If health checks fail, update DNS
# Point load balancer to previous version
aws elb set-load-balancer-listener-ssl-certificate ...
```

---

## Troubleshooting

### 502 Bad Gateway

**Check**:
1. Is application running? `systemctl status farmos`
2. Is database accessible? Test connection
3. Check logs: `/var/log/farmos/farmos.log`

**Fix**:
```bash
# Restart application
sudo systemctl restart farmos

# Check port binding
sudo lsof -i :8000

# Check Nginx proxy
sudo nginx -t && sudo systemctl restart nginx
```

### Database Connection Errors

**Check**:
1. Database service running? `systemctl status mysql`
2. Credentials correct in .env?
3. Database exists? `SHOW DATABASES;`

**Fix**:
```bash
# Test connection
mysql -h localhost -u user -p -e "SELECT 1;"

# Reset connection pool
# Restart application: systemctl restart farmos
```

### High Memory Usage

**Check**:
1. Memory leaks in code
2. Excessive caching
3. Database connection pool too large

**Fix**:
1. Review recent code changes
2. Reduce connection pool size
3. Restart application

---

## Timeline & Rollout Strategy

### Blue-Green Deployment

```
Week 1: Staging  → Full testing → Approval
Week 2: Deploy Blue (new version)
        Verify all checks pass
        Switch traffic gradually
        Monitor for 1 week
Week 3: If stable: Deprovision Green(old)
        If issues: Switch back to Green
```

### Canary Deployment

```
Step 1: Deploy new version to 5% of servers
Step 2: Monitor for 2 hours
Step 3: If metrics good, increase to 25%
Step 4: Monitor for 2 hours
Step 5: If metrics good, increase to 100%
Step 6: Keep old version for 1 week rollback
```

---

## References

- [PHP Manual](https://www.php.net/manual/en/)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [MySQL Backup & Recovery](https://dev.mysql.com/doc/)

---

**Document Version**: 1.0  
**Last Updated**: March 12, 2026  
**Status**: Production Ready ✅
