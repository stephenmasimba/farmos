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
- [ ] All tests pass: `pytest tests/ -v`
- [ ] Coverage > 80%: `pytest --cov`
- [ ] No security warnings: `bandit -r backend/`
- [ ] Code formatted: `black --check backend/`
- [ ] Type hints checked: `mypy backend/`
- [ ] Linting passes: `pylint backend/`

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
- [ ] All packages in requirements.txt
- [ ] No security vulnerabilities: `pip-audit`
- [ ] Compatible versions tested
- [ ] Production versions specified (no ~=)

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

### 2. Create Python Virtual Environment

```bash
# On Windows
python -m venv venv
venv\Scripts\activate

# On macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 4. Create Environment File

```bash
cp .env.example .env

# Edit .env with development values:
NODE_ENV=development
JWT_SECRET=<development-secret>
API_KEY=<development-key>
SECRET_KEY=<development-secret>
DATABASE_URL=mysql+pymysql://root:password@localhost:3306/farmos_dev
```

### 5. Initialize Database

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE farmos_dev;"

# Create tables
python -c "from common.database import Base, engine; Base.metadata.create_all(bind=engine)"

# Create demo users (optional)
python create_demo_users.py
```

### 6. Run Application

```bash
# Development with auto-reload
uvicorn app:app --reload

# The API is now at http://localhost:8000
# API docs at http://localhost:8000/docs
```

### 7. Run Tests

```bash
pytest tests/ -v

# With coverage
pytest tests/ --cov=backend --cov-report=html
```

---

## Staging Deployment

### Prerequisites

- ✅ All pre-deployment checks passed
- ✅ Staging server available
- ✅ MySQL 5.7+ installed
- ✅ Python 3.10+ installed
- ✅ Nginx installed

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

### 2. Python Environment Setup

```bash
cd /srv/farmos/begin_pyphp/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
pip list | grep -E "fastapi|sqlalchemy|bcrypt"
```

### 3. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit with staging values
nano .env

# Required settings:
NODE_ENV=staging
JWT_SECRET=<generate-new-secret>
API_KEY=<generate-new-key>
SECRET_KEY=<generate-new-secret>
DATABASE_URL=mysql+pymysql://farmos_user:secure_password@localhost:3306/farmos_staging
CORS_ORIGIN=https://staging.yourdomain.com
LOG_DIR=/var/log/farmos
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

# Create tables
python -c "from common.database import Base, engine; Base.metadata.create_all(bind=engine)"

# Verify tables
mysql -u farmos_user -p farmos_staging -e "SHOW TABLES;"
```

### 5. Nginx Configuration

Create `/etc/nginx/sites-available/farmos`:

```nginx
upstream farmos_backend {
    server 127.0.0.1:8000;
}

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
    
    # Proxy configuration
    location /api/ {
        proxy_pass http://farmos_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
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

### 6. Systemd Service Setup

Create `/etc/systemd/system/farmos.service`:

```ini
[Unit]
Description=FarmOS FastAPI Backend
After=network.target mysql.service

[Service]
Type=notify
User=deploy
WorkingDirectory=/srv/farmos/begin_pyphp/backend
Environment="PATH=/srv/farmos/begin_pyphp/backend/venv/bin"
EnvironmentFile=/srv/farmos/begin_pyphp/backend/.env
ExecStart=/srv/farmos/begin_pyphp/backend/venv/bin/uvicorn app:app --host 127.0.0.1 --port 8000 --workers 4

# Restart policy
Restart=on-failure
RestartSec=10s

# Logging
StandardOutput=append:/var/log/farmos/uvicorn.log
StandardError=append:/var/log/farmos/uvicorn-error.log

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable farmos
sudo systemctl start farmos
sudo systemctl status farmos
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

### 2. Docker Containerization (Recommended)

Create `Dockerfile`:

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

Build and push:
```bash
# Build image
docker build -t your-registry/farmos:1.0.0 .

# Push to registry
docker push your-registry/farmos:1.0.0

# Run container
docker run -d \
  --name farmos \
  --env-file .env \
  -p 8000:8000 \
  your-registry/farmos:1.0.0
```

### 3. Environment Configuration

```bash
# Production .env
NODE_ENV=production
JWT_SECRET=<very-long-random-string-64-chars>
API_KEY=<very-long-random-string-64-chars>
SECRET_KEY=<very-long-random-string-64-chars>
DATABASE_URL=mysql+pymysql://user:pass@rds.amazonaws.com:3306/farmos
REDIS_URL=redis://cache.amazonaws.com:6379/0
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com
LOG_LEVEL=INFO
LOG_FORMAT=json
LOG_DIR=/var/log/farmos
LOG_RETENTION_DAYS=90
NODE_ENV=production
```

### 4. Database Migration

```bash
# Connect to production database
mysql -h production-db.amazonaws.com -u admin -p farmos

# Create tables
python -c "from common.database import Base, engine; Base.metadata.create_all(bind=engine)"

# Create admin user
python create_demo_users.py --admin-password <secure-password>
```

### 5. Deployment

```bash
# Using Kubernetes (recommended for scale)
kubectl create namespace farmos
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Or using Docker Compose on single server
docker-compose up -d

# Or manual deployment
# SSH to prod server
ssh deploy@prod.farmos.local
cd /srv/farmos
git pull origin main
venv/bin/pip install -r requirements.txt
sudo systemctl restart farmos
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

# Load testing (using locust)
locust -f tests/locustfile.py --host=https://api.yourdomain.com

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

# If using containers
docker ps  # Find running container
docker stop <container-id>
docker run -d \
  --name farmos \
  --env-file .env \
  -p 8000:8000 \
  your-registry/farmos:previous-version
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

- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [MySQL Backup & Recovery](https://dev.mysql.com/doc/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Document Version**: 1.0  
**Last Updated**: March 12, 2026  
**Status**: Production Ready ✅
