# Docker Setup & Deployment Guide

## Overview

FarmOS uses Docker and Docker Compose for containerized development, testing, and production deployment. The setup includes:

- **PHP 8.2 FPM**: Application runtime with Nginx
- **MySQL 8.0**: Relational database
- **Redis**: Caching and rate limiting
- **React Frontend**: Web user interface (optional)
- **Development Tools**: Adminer, PHPMyAdmin (optional, dev only)

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 4GB+ RAM available
- 2GB disk space minimum

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/yourorg/farmos.git
cd farmos
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 3. Start Services

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f php

# Check service health
docker-compose ps
```

### 4. Initialize Database

```bash
# Create test data (optional)
docker-compose exec -T php php database/seed.php

# Run migrations
docker-compose exec -T php php database/migrate.php
```

### 5. Access Application

- **API**: http://localhost:8000/health
- **Frontend**: http://localhost:3000
- **PHPMyAdmin**: http://localhost:8081 (dev profile)
- **Adminer**: http://localhost:8080 (dev profile)

## Service Configuration

### PHP Backend

**Container**: `farmos-php`

```yaml
build:
  context: ./backend
  dockerfile: Dockerfile
environment:
  DB_HOST: mysql
  JWT_SECRET: your_secret_key
ports:
  - "8000:80"
```

Health Check: GET `/health` endpoint
Logs: `/var/log/farmos/`

### MySQL Database

**Container**: `farmos-mysql`

```yaml
image: mysql:8.0-alpine
environment:
  MYSQL_DATABASE: farmos
  MYSQL_USER: farmos_user
ports:
  - "3306:3306"
volumes:
  - mysql_data:/var/lib/mysql
```

Connection String:
```
mysql://farmos_user:farmos_password@mysql:3306/farmos
```

### Redis Cache

**Container**: `farmos-redis`

```yaml
image: redis:7-alpine
ports:
  - "6379:6379"
```

Used for:
- Session caching
- Rate limiting
- Query caching

### React Frontend

**Container**: `farmos-frontend` (optional)

```yaml
build:
  context: ./frontend-react
environment:
  REACT_APP_API_URL: http://localhost:8000
ports:
  - "3000:3000"
```

## Docker Compose Commands

### Start/Stop Services

```bash
# Start services (detached)
docker-compose up -d

# Stop services (keep data)
docker-compose stop

# Stop and remove containers
docker-compose down

# Restart services
docker-compose restart

# Restart specific service
docker-compose restart php
```

### View Logs

```bash
# View all logs
docker-compose logs

# Follow logs
docker-compose logs -f

# Follow logs for specific service
docker-compose logs -f php

# View last 100 lines
docker-compose logs --tail=100 php

# View logs since 5 minutes ago
docker-compose logs --since=5m php
```

### Execute Commands

```bash
# Run command in running container
docker-compose exec php php -v

# Run in database container
docker-compose exec mysql mysql -u root -p

# Run without allocating pseudo-TTY (useful in scripts)
docker-compose exec -T php php console.php
```

### Database Management

```bash
# Access MySQL CLI
docker-compose exec mysql mysql -u farmos_user -p farmos

# Backup database
docker-compose exec -T mysql mysqldump -u farmos_user -p farmos > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u farmos_user -p farmos < backup.sql
```

## Development Workflow

### 1. Local Development

```bash
# Start services with development profile
docker-compose --profile dev up -d

# View database in PHPMyAdmin
# http://localhost:8081

# Run tests
docker-compose exec php composer test

# Run linter
docker-compose exec php composer lint
```

### 2. Code Changes

```bash
# Changes in ./backend are immediately reflected
# (volume mount: ./backend:/app)

# If you modify composer.json:
docker-compose exec php composer install

# Restart PHP to load new dependencies
docker-compose restart php
```

### 3. Database Migrations

```bash
# Create migration
docker-compose exec php php database/make-migration CreateUsersTable

# Run migrations
docker-compose exec php php database/migrate.php

# Rollback migrations
docker-compose exec php php database/rollback.php
```

### 4. Run Tests

```bash
# Run all tests
docker-compose exec php composer test

# Run with coverage
docker-compose exec php composer test:coverage

# Run specific test file
docker-compose exec php vendor/bin/phpunit tests/Feature/LivestockTest.php

# Watch mode (requires watchmedo from watchdog)
docker-compose exec php phpunit-watch
```

## Production Deployment

### 1. Environment Setup

```bash
# Production environment
cp .env.example .env

# Configure for production
nano .env
```

Key settings:
```env
APP_ENV=production
DEBUG=false
DISPLAY_ERRORS=false
JWT_SECRET=<generate_secure_random_key>
DB_PASSWORD=<strong_password>
```

### 2. Build for Production

```bash
# Build with production optimizations
docker-compose build --no-cache

# Or using buildkit for faster builds
DOCKER_BUILDKIT=1 docker-compose build --no-cache
```

### 3. Database Initialization

```bash
# Run migrations in production
docker-compose exec php php database/migrate.php

# Seed initial data if needed
docker-compose exec php php database/seed.php
```

### 4. Security Considerations

```bash
# Change default MySQL password
docker-compose down
# Edit .env with strong password
docker-compose up -d mysql

# Set proper file permissions
docker-compose exec php chown -R www-data:www-data /app

# Enable SSL/HTTPS
# Configure reverse proxy (Nginx, Traefik, etc.)
```

### 5. Scaling

```bash
# Scale PHP service (if using Swarm/Kubernetes)
docker-compose up -d --scale php=3

# Load balancer needed for multiple PHP instances
# Update docker-compose.yml to include load balancer
```

## Monitoring & Maintenance

### Health Checks

```bash
# Check service status
docker-compose ps

# Health endpoints
curl http://localhost:8000/health

# Docker health status
docker ps --format "{{.Names}}\t{{.Status}}"
```

### Logs & Debugging

```bash
# View application errors
docker-compose logs php | grep ERROR

# Check database logs
docker-compose logs mysql | grep ERROR

# Check Redis logs
docker-compose logs redis

# System logs
docker logs farmos-php --tail=100
```

### Performance Monitoring

```bash
# CPU/Memory usage
docker stats

# Container resource limits
docker-compose exec php free -m
docker-compose exec mysql free -m

# Database query log
docker-compose exec mysql mysql -u root -p -e "SET GLOBAL general_log = 'ON';"
```

### Database Maintenance

```bash
# Check database size
docker-compose exec mysql mysql -u farmos_user -p -e "SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024,2) FROM information_schema.tables GROUP BY table_schema;"

# Optimize tables
docker-compose exec mysql mysqlcheck -u farmos_user -p --optimize farmos

# Backup with timestamp
docker-compose exec -T mysql mysqldump -u farmos_user -p farmos > backup_$(date +%Y%m%d_%H%M%S).sql
```

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker-compose logs php

# Verify image built correctly
docker images | grep farmos

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Database Connection Error

```bash
# Check MySQL is running
docker-compose exec mysql mysqladmin ping

# Verify credentials in .env
cat .env | grep DB_

# Test connection
docker-compose exec php php -r "new PDO('mysql:host=mysql;dbname=farmos', 'farmos_user', 'farmos_password');"
```

### High Memory Usage

```bash
# Check container memory limits
docker stats

# Adjust in docker-compose.yml
services:
  php:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

### Port Already in Use

```bash
# Check what's using the port
lsof -i :8000

# Change port in .env
API_PORT=8001

# Or kill the process
kill -9 <PID>
```

### Slow Performance

```bash
# Check Redis connectivity
docker-compose exec php redis-cli ping

# Clear Redis cache
docker-compose exec redis redis-cli FLUSHALL

# Check database queries
docker-compose exec mysql mysql -u farmos_user -p -e "SET GLOBAL slow_query_log = 'ON'; SET GLOBAL long_query_time = 0.5;"
```

## Network Configuration

### Internal Docker Network

All services communicate via `farmos-network`:

```
php:8000 <-> mysql:3306
php:8000 <-> redis:6379
frontend:3000 <-> php:8000 (via host network)
```

### External Access

- **API**: Host port 8000 → Container port 80 (Nginx)
- **Frontend**: Host port 3000 → Container port 3000
- **Database**: Host port 3306 → Container port 3306 (for tools like MySQL Workbench)

### Custom Network

To use custom network bridge:

```bash
docker network create farmos-custom
docker-compose --network-name farmos-custom up -d
```

## Backup & Recovery

### Database Backup

```bash
# Backup all databases
docker-compose exec -T mysql mysqldump -u root -p --all-databases > backup_full.sql

# Backup specific database
docker-compose exec -T mysql mysqldump -u farmos_user -p farmos > backup_farmos.sql

# Backup with structure only
docker-compose exec -T mysql mysqldump -u farmos_user -p --no-data farmos > backup_schema.sql
```

### Database Recovery

```bash
# Restore from backup
docker-compose exec -T mysql mysql -u farmos_user -p farmos < backup_farmos.sql

# Verify restoration
docker-compose exec mysql mysql -u farmos_user -p farmos -e "SELECT COUNT(*) FROM users;"
```

### Volume Backup

```bash
# Backup named volume
docker run --rm -v farmos_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz -C /data .

# Restore volume
docker run --rm -v farmos_mysql_data:/data -v $(pwd):/backup alpine tar xzf /backup/mysql_backup.tar.gz -C /data
```

## Advanced Configuration

### Custom Nginx Configuration

Edit `backend/config/nginx/default.conf`:

```nginx
server {
    listen 80;
    server_name _;
    
    root /app/public;
    index index.php;
    
    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### Custom PHP Configuration

Edit `backend/config/php/php.ini`:

```ini
memory_limit = 256M
max_execution_time = 300
upload_max_filesize = 100M
post_max_size = 100M
```

### Supervisor Configuration

Manage multiple processes via supervisor. Edit `backend/config/supervisor/supervisord.conf`:

```ini
[program:php-fpm]
command=/usr/local/sbin/php-fpm
autostart=true
autorestart=true
```

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/03-compose-file/)
- [MySQL Docker Hub](https://hub.docker.com/_/mysql)
- [PHP Docker Hub](https://hub.docker.com/_/php)
- [Redis Docker Hub](https://hub.docker.com/_/redis)
