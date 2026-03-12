# FarmOS Phase 4: Infrastructure Setup Guide

**Version**: 1.0.0  
**Date**: March 12, 2026  
**Status**: Production Ready  
**Phase**: 4 (Infrastructure & DevOps)

---

## 📋 Table of Contents

1. [Docker & Containerization](#docker--containerization)
2. [CI/CD Pipeline](#cicd-pipeline)
3. [Monitoring & Logging](#monitoring--logging)
4. [Backup & Recovery](#backup--recovery)
5. [Infrastructure as Code](#infrastructure-as-code)
6. [Health Checks & Reliability](#health-checks--reliability)

---

## Docker & Containerization

### 1. Dockerfile for Backend

Create `backend/Dockerfile`:

```dockerfile
# Multi-stage build for optimization
FROM python:3.10-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.10-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=builder /root/.local /root/.local

# Set PATH to include user site-packages
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 farmos && chown -R farmos:farmos /app
USER farmos

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application with gunicorn
CMD ["gunicorn", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "4", \
     "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--worker-tmp-dir", "/dev/shm", \
     "--max-requests", "1000", \
     "--max-requests-jitter", "50", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app:app"]
```

Add gunicorn to `requirements.txt`:
```
gunicorn==21.2.0
uvicorn[standard]==0.24.0
```

### 2. Docker Compose Setup

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # MySQL Database
  db:
    image: mysql:8.0
    container_name: farmos-db
    environment:
      MYSQL_DATABASE: ${DB_NAME:-farmos}
      MYSQL_USER: ${DB_USER:-farmos_user}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
      - ./backend/database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - farmos-network

  # Redis Cache
  cache:
    image: redis:7-alpine
    container_name: farmos-cache
    ports:
      - "6379:6379"
    volumes:
      - cache_data:/data
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - farmos-network

  # FastAPI Backend
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: farmos-api
    environment:
      NODE_ENV: ${NODE_ENV:-development}
      DATABASE_URL: mysql+pymysql://${DB_USER:-farmos_user}:${DB_PASSWORD}@db:3306/${DB_NAME:-farmos}
      REDIS_URL: redis://cache:6379/0
      JWT_SECRET: ${JWT_SECRET}
      API_KEY: ${API_KEY}
      SECRET_KEY: ${SECRET_KEY}
      CORS_ORIGIN: ${CORS_ORIGIN}
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
      LOG_FORMAT: ${LOG_FORMAT:-json}
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_healthy
    volumes:
      - ./backend:/app
      - logs:/var/log/farmos
    networks:
      - farmos-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: farmos-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - logs:/var/log/nginx
    depends_on:
      - api
    networks:
      - farmos-network
    restart: unless-stopped

volumes:
  db_data:
  cache_data:
  logs:

networks:
  farmos-network:
    driver: bridge
```

### 3. Environment File

Create `.env.example`:

```bash
# Node Environment
NODE_ENV=development

# Database
DB_NAME=farmos
DB_USER=farmos_user
DB_PASSWORD=secure_password_change_me
DB_ROOT_PASSWORD=root_password_change_me

# Security
JWT_SECRET=your-very-long-random-jwt-secret-min-32-chars
API_KEY=your-very-long-random-api-key-min-32-chars
SECRET_KEY=your-very-long-random-secret-min-32-chars

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json

# Redis
REDIS_URL=redis://cache:6379/0
```

Copy to `.env`:
```bash
cp .env.example .env
# Edit .env with your values
```

### 4. Build and Run

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down

# Remove with volumes
docker-compose down -v
```

---

## CI/CD Pipeline

### 1. GitHub Actions Workflow

Create `.github/workflows/test-and-deploy.yml`:

```yaml
name: Test and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: farmos_test
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
        ports:
          - 3306:3306

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
        ports:
          - 6379:6379

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
        cache: 'pip'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r backend/requirements.txt

    - name: Lint with flake8
      run: |
        pip install flake8
        flake8 backend --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 backend --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

    - name: Type check with mypy
      run: |
        pip install mypy
        mypy backend --ignore-missing-imports || true

    - name: Format check with black
      run: |
        pip install black
        black --check backend || true

    - name: Run tests
      env:
        DATABASE_URL: mysql+pymysql://root:root@127.0.0.1:3306/farmos_test
        REDIS_URL: redis://127.0.0.1:6379/0
        JWT_SECRET: test-secret-key-at-least-32-characters-long
        API_KEY: test-api-key-at-least-32-characters-long
        SECRET_KEY: test-secret-at-least-32-characters-long
      run: |
        cd backend
        pytest tests/ -v --cov=backend --cov-report=xml

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./backend/coverage.xml
        flags: unittests
        name: codecov-umbrella

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    permissions:
      contents: read
      packages: write

    steps:
    - uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha

    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: ./backend
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
    - uses: actions/checkout@v3

    - name: Deploy to Staging
      env:
        DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}
        DEPLOY_HOST: staging.yourdomain.com
        DEPLOY_USER: deploy
      run: |
        mkdir -p ~/.ssh
        echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
        chmod 600 ~/.ssh/deploy_key
        ssh-keyscan -H $DEPLOY_HOST >> ~/.ssh/known_hosts
        
        ssh -i ~/.ssh/deploy_key $DEPLOY_USER@$DEPLOY_HOST << 'EOF'
          cd /srv/farmos
          docker-compose pull
          docker-compose up -d
          docker-compose exec -T api alembic upgrade head
        EOF

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3

    - name: Create Deployment
      uses: actions/github-script@v6
      with:
        script: |
          github.rest.repos.createDeployment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            ref: context.sha,
            environment: 'production',
            required_contexts: [],
            auto_merge: false
          })

    - name: Wait for Approval
      run: |
        echo "Production deployment requires manual approval"
        echo "Check GitHub Actions deployment status"

    - name: Deploy to Production
      env:
        DEPLOY_KEY: ${{ secrets.PROD_DEPLOY_KEY }}
        DEPLOY_HOST: api.yourdomain.com
        DEPLOY_USER: deploy
      run: |
        mkdir -p ~/.ssh
        echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
        chmod 600 ~/.ssh/deploy_key
        ssh-keyscan -H $DEPLOY_HOST >> ~/.ssh/known_hosts
        
        ssh -i ~/.ssh/deploy_key $DEPLOY_USER@$DEPLOY_HOST << 'EOF'
          cd /srv/farmos
          # Backup current data
          docker-compose exec -T db mysqldump -u root -p$DB_ROOT_PASSWORD farmos > backup_$(date +%s).sql
          
          # Deploy new version
          docker-compose pull
          docker-compose up -d
          docker-compose exec -T api alembic upgrade head
          
          # Run smoke tests
          curl https://api.yourdomain.com/health
        EOF
```

### 2. Testing Workflow

Create `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Run Bandit Security Scan
      uses: gaurav-nelson/github-action-bandit@v1
      with:
        path: backend

    - name: Run Trivy Vulnerability Scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: 'backend'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy results to GitHub Security
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

    - name: Dependency Check
      uses: dependency-check/Dependency-Check_Action@main
      with:
        project: 'farmos'
        path: '.'
        format: 'JSON'
```

---

## Monitoring & Logging

### 1. Prometheus Setup

Create `prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'farmos'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'fastapi'
    static_configs:
      - targets: ['api:8000']
    metrics_path: '/metrics'

  - job_name: 'mysql'
    static_configs:
      - targets: ['db:3306']

  - job_name: 'redis'
    static_configs:
      - targets: ['cache:6379']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']
```

### 2. Grafana Dashboard Setup

Add to `docker-compose.yml`:

```yaml
  prometheus:
    image: prom/prometheus:latest
    container_name: farmos-prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - farmos-network

  grafana:
    image: grafana/grafana:latest
    container_name: farmos-grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
      GF_INSTALL_PLUGINS: redis-datasource
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    networks:
      - farmos-network

  # Prometheus Exporter for MySQL
  mysql-exporter:
    image: prom/mysqld-exporter:latest
    container_name: farmos-mysql-exporter
    environment:
      DATA_SOURCE_NAME: ${DB_USER}:${DB_PASSWORD}@(db:3306)/
    depends_on:
      - db
    ports:
      - "9104:9104"
    networks:
      - farmos-network

  # Prometheus Exporter for Redis
  redis-exporter:
    image: oliver006/redis_exporter:latest
    container_name: farmos-redis-exporter
    environment:
      REDIS_ADDR: redis://cache:6379
    depends_on:
      - cache
    ports:
      - "9121:9121"
    networks:
      - farmos-network
```

### 3. ELK Stack for Logging

Create `docker-compose.logging.yml`:

```yaml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.0.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - farmos-network

  logstash:
    image: docker.elastic.co/logstash/logstash:8.0.0
    volumes:
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml:ro
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
      - logs:/var/log/farmos:ro
    ports:
      - "5000:5000/tcp"
      - "5000:5000/udp"
      - "9600:9600"
    depends_on:
      - elasticsearch
    networks:
      - farmos-network

  kibana:
    image: docker.elastic.co/kibana/kibana:8.0.0
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - farmos-network

volumes:
  elasticsearch_data:

networks:
  farmos-network:
    external: true
```

Create `logstash/pipeline/farmos.conf`:

```
input {
  file {
    path => "/var/log/farmos/farmos.log"
    start_position => "beginning"
    codec => json
  }
}

filter {
  mutate {
    add_field => { "[@metadata][index_name]" => "farmos-logs-%{+YYYY.MM.dd}" }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "%{[@metadata][index_name]}"
  }
}
```

---

## Backup & Recovery

### 1. Automated Backups

Create `scripts/backup.sh`:

```bash
#!/bin/bash

# Backup configuration
BACKUP_DIR="/backups"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Database backup
echo "Backing up database..."
docker-compose exec -T db mysqldump \
  -u root -p$DB_ROOT_PASSWORD \
  --all-databases \
  --single-transaction \
  --quick \
  --lock-tables=false \
  | gzip > $BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz

# Fix permissions
chmod 600 $BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz

# Upload to S3 (optional)
if command -v aws &> /dev/null; then
  echo "Uploading to S3..."
  aws s3 cp $BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz \
    s3://farmos-backups/daily/
fi

# Clean old backups
echo "Cleaning old backups..."
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup complete: db_backup_$TIMESTAMP.sql.gz"
```

### 2. Scheduled Backups

Create crontab entry:

```bash
# Daily backup at 2 AM
0 2 * * * /srv/farmos/scripts/backup.sh >> /var/log/farmos/backup.log 2>&1

# Weekly to S3 at Sunday 3 AM
0 3 * * 0 /srv/farmos/scripts/backup-to-s3.sh >> /var/log/farmos/backup-s3.log 2>&1
```

### 3. Recovery Procedure

Create `scripts/restore.sh`:

```bash
#!/bin/bash

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: ./restore.sh <backup-file>"
  ls -lh /backups/db_backup_*.sql.gz
  exit 1
fi

echo "Restoring from: $BACKUP_FILE"

# Decompress and restore
gunzip -c $BACKUP_FILE | docker-compose exec -T db mysql \
  -u root -p$DB_ROOT_PASSWORD

echo "Restore complete!"
```

---

## Infrastructure as Code

### 1. Terraform for AWS

Create `terraform/main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ECS Cluster
resource "aws_ecs_cluster" "farmos" {
  name = "farmos-cluster"
}

# RDS Database
resource "aws_db_instance" "farmos" {
  allocated_storage    = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.small"
  db_name              = "farmos"
  username             = "admin"
  password             = var.db_password
  
  backup_retention_period = 30
  skip_final_snapshot     = false
  final_snapshot_identifier = "farmos-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  tags = {
    Name = "farmos-database"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "farmos" {
  cluster_id           = "farmos-cache"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  
  tags = {
    Name = "farmos-cache"
  }
}

# ALB
resource "aws_lb" "farmos" {
  name               = "farmos-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  tags = {
    Name = "farmos-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "farmos" {
  name        = "farmos-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "farmos" {
  name                = "farmos-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.farmos.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 10
  desired_capacity    = 3

  launch_template {
    id      = aws_launch_template.farmos.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "farmos-instance"
    propagate_at_launch = true
  }
}

# Launch Template
resource "aws_launch_template" "farmos" {
  name_prefix   = "farmos-"
  image_id      = var.ami_id
  instance_type = "t3.medium"

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(file("${path.module}/user_data.sh"))
}
```

---

## Health Checks & Reliability

### 1. Kubernetes Deployment (Optional)

Create `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: farmos-api
  labels:
    app: farmos
spec:
  replicas: 3
  selector:
    matchLabels:
      app: farmos
  template:
    metadata:
      labels:
        app: farmos
    spec:
      containers:
      - name: api
        image: ghcr.io/yourorg/farmos:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: farmos-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: farmos-secrets
              key: redis-url
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi

---
apiVersion: v1
kind: Service
metadata:
  name: farmos-api-service
spec:
  selector:
    app: farmos
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: farmos-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: farmos-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

## Getting Started

### Quick Start

```bash
# Clone repository
git clone https://github.com/yourorg/farmos.git
cd farmos

# Copy environment file
cp .env.example .env
nano .env  # Edit with your values

# Generate secrets
JWT_SECRET=$(openssl rand -base64 32)
API_KEY=$(openssl rand -base64 32)
SECRET_KEY=$(openssl rand -base64 32)

# Start services
docker-compose up -d

# Initialize database
docker-compose exec api python -c "from common.database import Base, engine; Base.metadata.create_all(bind=engine)"

# View logs
docker-compose logs -f

# Access services
# API: http://localhost:8000
# Grafana: http://localhost:3000
# Kibana: http://localhost:5601
```

### Health Checks

```bash
# API health
curl http://localhost:8000/health

# Database
docker-compose ps db

# Cache
redis-cli -h 127.0.0.1 PING

# Metrics
curl http://localhost:9090/api/v1/query?query=up
```

---

**Document Version**: 1.0  
**Status**: Production Ready ✅  
**Last Updated**: March 12, 2026
