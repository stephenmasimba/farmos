# FarmOS Comprehensive Troubleshooting Guide

**Version**: 1.0.0  
**Date**: March 12, 2026  
**Status**: Production Ready  
**For**: Ops, DevOps, Support Teams

---

## 📋 Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Common Errors & Solutions](#common-errors--solutions)
3. [Log Analysis](#log-analysis)
4. [Performance Debugging](#performance-debugging)
5. [Database Troubleshooting](#database-troubleshooting)
6. [API Troubleshooting](#api-troubleshooting)
7. [Security Incident Response](#security-incident-response)
8. [Deployment Issues](#deployment-issues)
9. [Health Checks & Monitoring](#health-checks--monitoring)
10. [Escalation & Support](#escalation--support)

---

## Quick Diagnostics

### System Health Check

```bash
#!/bin/bash
# scripts/health-check.sh

echo "=== FarmOS System Health Check ==="
echo ""

# Check if application services are running
echo "1. Application Status:"
systemctl is-active --quiet nginx && echo "   ✅ Nginx is running" || echo "   ❌ Nginx is NOT running"
systemctl is-active --quiet php-fpm && echo "   ✅ PHP-FPM is running" || echo "   ❌ PHP-FPM is NOT running"

# Check database connectivity
echo ""
echo "2. Database Status:"
mysql -u farmos_user -p -e "SELECT 1;" 2>/dev/null && \
    echo "   ✅ MySQL is accessible" || \
    echo "   ❌ MySQL connection failed"

# Check Redis connectivity
echo ""
echo "3. Cache Status:"
redis-cli -h localhost -p 6379 PING 2>/dev/null && \
    echo "   ✅ Redis is running" || \
    echo "   ❌ Redis is not accessible"

# Check API health endpoint
echo ""
echo "4. API Health:"
curl -s http://127.0.0.1:8001/health | grep -q "ok" && \
    echo "   ✅ API is responding" || \
    echo "   ❌ API is not responding"
 

# Check disk space
echo ""
echo "5. Disk Usage:"
df -h | grep -E "/$|/var$" | awk '{print "   " $5 " used on " $6}'

# Check memory usage
echo ""
echo "6. Memory Usage:"
free -h | awk '/Mem:/ {print "   " $3 " of " $2 " used (" int($3/$2*100) "%)"}'

# Check CPU load
echo ""
echo "7. CPU Load:"
uptime | awk -F'load average:' '{print "   " $2}'

echo ""
echo "=== Check Complete ==="
```

Run health check:
```bash
chmod +x scripts/health-check.sh
./scripts/health-check.sh
```

---

## Common Errors & Solutions

### Error 1: 502 Bad Gateway

**Symptoms**:
- Browser shows "502 Bad Gateway"
- Nginx logs show upstream error
- Clients cannot access API

**Diagnosis**:
```bash
# Check Nginx error log
tail -f /var/log/nginx/error.log

# Check web server / PHP runtime
systemctl status nginx
systemctl status php-fpm

# Check backend logs
tail -f /var/log/farmos/farmos.log
```

**Solutions**:

1. **Backend not running**:
   ```bash
   # Restart services
   sudo systemctl restart nginx
   sudo systemctl restart php-fpm
   
   # Check service status
   sudo systemctl status nginx
   sudo systemctl status php-fpm
   
   # View service logs
   sudo journalctl -u nginx -n 50
   sudo journalctl -u php-fpm -n 50
   ```

2. **Port not bound**:
   ```bash
   # Check if port 8001 is listening (dev server)
   sudo lsof -i :8001
   
   # Check for process using port
   sudo netstat -tulpn | grep :8001
   ```

3. **Database connection error**:
   ```bash
   # Test database connection
   mysql -u farmos_user -p -h localhost -e "SELECT 1;"
   
   # Check database URL in .env
   echo $DATABASE_URL
   ```

**Resolution** (Priority):
- [ ] Restart backend service
- [ ] Check database connectivity
- [ ] Verify environment variables
- [ ] Check disk space (may prevent startup)
- [ ] Review backend logs for error messages

---

### Error 2: Database Connection Refused

**Symptoms**:
- "Connection refused" errors
- Applications cannot connect to database
- Slow queries timing out

**Diagnosis**:
```bash
# Check if MySQL is running
systemctl status mysql

# Check if MySQL is listening
netstat -tulpn | grep mysql

# Test local connection
mysql -u root -p -e "SELECT VERSION();"

# Test application connection
mysql -u farmos_user -p -h localhost -e "SELECT COUNT(*) FROM users;"
```

**Solutions**:

1. **MySQL service not running**:
   ```bash
   # Start MySQL
   sudo systemctl start mysql
   
   # Enable on boot
   sudo systemctl enable mysql
   
   # Verify
   sudo systemctl status mysql
   ```

2. **Authentication failed**:
   ```bash
   # Reset password
   sudo mysql -u root << EOF
   ALTER USER 'farmos_user'@'localhost' IDENTIFIED BY 'new_password';
   FLUSH PRIVILEGES;
   EOF
   
   # Update application .env
   nano .env  # Update DATABASE_URL
   ```

3. **Connection limit reached**:
   ```bash
   # Check current connections
   mysql -u root -p -e "SHOW PROCESSLIST;" | wc -l
   
   # Increase max connections
   mysql -u root -p -e "SET GLOBAL max_connections=1000;"
   
   # Make permanent by editing /etc/mysql/mysql.conf.d/mysqld.cnf
   # Add: max_connections=1000
   ```

---

### Error 3: 401 Unauthorized / Token Expired

**Symptoms**:
- API returns 401 Unauthorized
- "Invalid token" or "Token expired" messages
- Login works but requests fail

**Diagnosis**:
```bash
# Get a valid token
curl -X POST http://127.0.0.1:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'

# Verify token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://127.0.0.1:8001/api/auth/me
```

**Solutions**:

1. **Token expired** (Normal behavior):
   ```bash
   # Use refresh endpoint
   curl -X POST http://127.0.0.1:8001/api/auth/refresh-token \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

2. **Invalid token format**:
   ```bash
   # Correct format: "Bearer <token>"
   curl -H "Authorization: Bearer eyJhbGci..." \
     http://127.0.0.1:8001/api/auth/me
   ```

3. **JWT secret mismatch**:
   ```bash
   # Check JWT_SECRET in .env
   echo $JWT_SECRET
   
   # Verify length (minimum 32 chars)
   echo $JWT_SECRET | wc -c
   
   # Regenerate if necessary
   openssl rand -base64 32
   ```

---

### Error 4: 429 Too Many Requests

**Symptoms**:
- "Rate limit exceeded" errors
- Cannot make more requests for a period
- Sudden increase in failed logins

**Understanding Rate Limits**:
```
Auth endpoints: 5 requests per minute per IP
API endpoints: 100 requests per minute per IP
Upload endpoints: 50 requests per hour per IP
```

**Solutions**:

1. **Normal rate limit (expected behavior)**:
   ```bash
   # Wait for window to reset (typically 60 seconds)
   # Or implement exponential backoff in client
   
   # Check rate limit headers
   curl -v http://127.0.0.1:8001/api/livestock 2>&1 | grep X-RateLimit
   ```

2. **Brute force attack suspected**:
   ```bash
   # Check logs for repeated failed logins
   grep "failed attempt" /var/log/farmos/farmos.log | tail -20
   
   # Block IP temporarily (using iptables)
   sudo iptables -I INPUT -s <ip-address> -j DROP
   
   # Check rate limiter status
   redis-cli INFO | grep connected_clients
   ```

3. **Adjust rate limits** (if needed):
   ```python
   # backend/middleware/rate_limiting.py
   # Modify limits based on load
   AUTH_LIMITER = SlidingWindowLimiter(5, 60)  # 5 req/min
   API_LIMITER = SlidingWindowLimiter(100, 60)  # 100 req/min
   ```

---

### Error 5: Disk Space Full

**Symptoms**:
- "No space left on device" errors
- Application startup fails
- Database cannot write

**Diagnosis**:
```bash
# Check overall disk usage
df -h

# Check specific partitions
df -i /var/

# Find large files
du -sh /* | sort -rh | head -10

# Check database size
du -sh /var/lib/mysql

# Check log sizes
du -sh /var/log/farmos/
ls -lh /var/log/farmos/*.log
```

**Solutions**:

1. **Clear old logs**:
   ```bash
   # Rotate logs
   sudo logrotate -f /etc/logrotate.d/farmos
   
   # Or manually archive old logs
   gzip /var/log/farmos/*.log.1
   mv /var/log/farmos/*.log.*.gz /archive/
   ```

2. **Clean MySQL temp files**:
   ```bash
   # Find temp files
   ls -la /var/lib/mysql/tmp/
   
   # Safe cleanup (with MySQL stopped)
   sudo systemctl stop mysql
   sudo rm -f /var/lib/mysql/tmp/*
   sudo systemctl start mysql
   ```

3. **Remove old backups**:
   ```bash
   # List backups
   ls -lh /backups/
   
   # Keep only last 7 days
   find /backups -name "*.sql.gz" -mtime +7 -delete
   ```

---

## Log Analysis

### Log File Locations

```
Application Logs:  /var/log/farmos/farmos.log
                   /var/log/farmos/farmos-error.log
Nginx Logs:        /var/log/nginx/access.log
                   /var/log/nginx/error.log
MySQL Logs:        /var/log/mysql/error.log
                   /var/log/mysql/slow-query.log
Systemd Logs:      journalctl -u farmos
```

### Real-Time Monitoring

```bash
# Monitor application logs in real-time
tail -f /var/log/farmos/farmos.log

# Follow with line numbers
tail -f -n 50 /var/log/farmos/farmos.log

# Search and follow
grep -f <(echo "ERROR") /var/log/farmos/farmos.log | tail -f

# Monitor multiple logs
tail -f /var/log/farmos/*.log /var/log/nginx/error.log
```

### Log Filtering

```bash
# Find all errors in last hour
grep "ERROR" /var/log/farmos/farmos.log | grep "$(date -d '1 hour ago' +'%Y-%m-%d %H')"

# Find slow queries
grep "duration_ms.*[0-9]{4}" /var/log/farmos/farmos.log

# Count errors by type
grep "ERROR" /var/log/farmos/farmos.log | cut -d: -f3 | sort | uniq -c | sort -rn

# Find requests from specific IP
grep "X-Real-IP: 192.168.1.1" /var/log/nginx/access.log

# Find failed authentication
grep "Authentication failed" /var/log/farmos/farmos.log | tail -20
```

### Log Analysis Script

```bash
#!/bin/bash
# scripts/analyze-logs.sh

echo "=== Log Analysis - Last 24 Hours ==="
echo ""

# Count errors
echo "Error Summary:"
grep ERROR /var/log/farmos/farmos.log | wc -l
echo ""

# Top error messages
echo "Top Errors:"
grep ERROR /var/log/farmos/farmos.log | cut -d: -f4- | sort | uniq -c | sort -rn | head -5
echo ""

# Database errors
echo "Database Errors:"
grep "database\|sqlalchemy\|pymysql" /var/log/farmos/farmos-error.log | wc -l
echo ""

# Authentication failures
echo "Auth Failures:"
grep "Authentication failed" /var/log/farmos/farmos.log | wc -l
echo ""

# Slow queries
echo "Slow Queries (>1s):"
grep "duration_ms" /var/log/farmos/farmos.log | awk -F'duration_ms[:\"]' '{print $2}' | awk '$1 > 1000 {print}' | wc -l
echo ""

# API errors by endpoint
echo "API Endpoints with Errors:"
grep "ERROR.*method=\"" /var/log/farmos/farmos.log | grep -o 'path="[^"]*' | sort | uniq -c | sort -rn | head -5
```

---

## Performance Debugging

### Slow Query Diagnosis

```bash
# Enable slow query log
mysql -u root -p -e "SET GLOBAL slow_query_log = 'ON';"
mysql -u root -p -e "SET GLOBAL long_query_time = 0.5;"

# Monitor slow queries
tail -f /var/log/mysql/slow-query.log

# Analyze slow query log
mysqldumpslow /var/log/mysql/slow-query.log | head -20

# Find slowest queries
mysqldumpslow -s at /var/log/mysql/slow-query.log | head -10
```

### Database Query Analysis

```bash
# EXPLAIN query plans
mysql -u root -p -e "EXPLAIN SELECT * FROM livestock WHERE farm_id = 1 AND status = 'active';"

# Check index usage
mysql -u root -p << EOF
SELECT OBJECT_SCHEMA, OBJECT_NAME, COUNT_STAR
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'farmos'
ORDER BY COUNT_STAR DESC;
EOF
```

### API Performance Metrics

```bash
# Response time statistics
curl -s http://127.0.0.1:8001/api/livestock 2>&1 | grep "X-Process-Time"

# Load test with Apache Bench
ab -n 1000 -c 50 http://127.0.0.1:8001/api/livestock

# Profile with timing
time curl http://127.0.0.1:8001/api/livestock

# Monitor request processing time
grep "X-Process-Time" /var/log/nginx/access.log | awk -F'=|ms' '{sum+=$2; count++} END {print "Avg: " sum/count "ms"}'
```

### Memory Leak Detection

```bash
# Monitor memory over time
watch -n 1 'ps aux | grep php-fpm | grep -v grep | awk "{print \$6}"'

# Check process memory
ps -aux | grep php-fpm | awk '{print $2, $6}'

# Memory by application
top -p $(pgrep -f php-fpm) -b -n 1

# If memory constantly increasing:
# 1. Check for circular imports
# 2. Look for unbounded caches
# 3. Review database connections
# 4. Check for resource leaks
```

---

## Database Troubleshooting

### Connection Issues

```bash
# Test connection
mysql -u farmos_user -p -h localhost -e "SELECT 1;"

# Test with TCP
mysql -u farmos_user -p -h 127.0.0.1 -e "SELECT 1;"

# Check port binding
sudo lsof -i :3306

# Test from application server
ssh deploy@app "mysql -u farmos_user -p -h db.internal -e 'SELECT VERSION();'"
```

### Data Corruption

```bash
# Check table integrity
mysqlcheck -u root -p --check farmos

# Repair corrupted tables
mysqlcheck -u root -p --repair farmos

# Full check with verbose
mysqlcheck -u root -p -v --check-upgrade farmos
```

### Lock Detection

```bash
# Find locked tables
mysql -u root -p -e "SHOW OPEN TABLES WHERE In_use > 0;"

# Show processlist
mysql -u root -p -e "SHOW PROCESSLIST;"

# Kill long-running query (ID 123)
mysql -u root -p -e "KILL 123;"

# Show transactions
mysql -u root -p -e "SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;"
```

### Replication Issues (if applicable)

```bash
# Check replica status
mysql -u root -p -e "SHOW SLAVE STATUS\G"

# Skip bad event
mysql -u root -p -e "SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1; START SLAVE;"

# Resync replica
mysql -u root -p -e "CHANGE MASTER TO MASTER_LOG_FILE='', MASTER_LOG_POS=0;"
```

---

## API Troubleshooting

### Request/Response Issues

```bash
# Test basic endpoint
curl -v http://127.0.0.1:8001/health

# Test with auth
TOKEN=$(curl -s -X POST http://127.0.0.1:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}' | jq -r '.access_token')

curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8001/api/livestock

# Check response headers
curl -i http://127.0.0.1:8001/health | head -20

# Test with custom headers
curl -H "X-Real-IP: 192.168.1.1" http://127.0.0.1:8001/health
```

### Search Path Issues

```bash
# Test CORS
curl -H "Origin: https://yourdomain.com" \
  -H "Access-Control-Request-Method: GET" \
  -v http://127.0.0.1:8001/api/livestock 2>&1 | grep "Access-Control"

# Check CORS configuration
echo $CORS_ORIGIN

# Fix CORS issues
# Update .env: CORS_ORIGIN=https://yourdomain.com
```

### Timeout Issues

```bash
# Increase timeout
curl --max-time 30 http://127.0.0.1:8001/api/livestock

# Check connection timeout
curl --connect-timeout 10 http://127.0.0.1:8001/health

# Server-side timeout check
grep "timeout" /var/log/farmos/farmos.log

# HTTP timeout setting (nginx)
# Add to server block:
# proxy_connect_timeout 60s;
# proxy_send_timeout 60s;
# proxy_read_timeout 60s;
```

---

## Security Incident Response

### Suspected Brute Force Attack

```bash
# Check failed login attempts
grep "Authentication failed" /var/log/farmos/farmos.log | \
  awk '{print $NF}' | sort | uniq -c | sort -rn | head -10

# Block attacking IP with iptables
ATTACKER_IP="192.168.1.100"
sudo iptables -I INPUT -s $ATTACKER_IP -j DROP

# Make permanent
sudo iptables-save > /etc/iptables/rules.v4

# Or use fail2ban if installed
sudo fail2ban-client set farmos banip $ATTACKER_IP

# Monitor for continued attempts
tail -f /var/log/farmos/farmos.log | grep "Authentication failed"
```

### Suspected Unauthorized Access

```bash
# Find suspicious logins
grep "logged in" /var/log/farmos/farmos.log | \
  tail -50 | awk '{print NF, $(NF-1)}'

# Check user activities
grep "user_id\|admin" /var/log/farmos/farmos.log | tail -100

# List recent API calls
grep "GET\|POST\|PUT\|DELETE" /var/log/nginx/access.log | tail -50

# Check for data exports
grep "export\|dump\|download" /var/log/farmos/farmos.log
```

### Suspected SQL Injection Attempt

```bash
# Look for SQL keywords in request logs
grep -i "union\|select\|insert\|delete\|drop" /var/log/nginx/access.log | head -20

# Check application error logs
grep "sql\|database\|query" /var/log/farmos/farmos-error.log | head -20

# Enable SQL logging (careful - performance impact)
mysql -u root -p -e "SET GLOBAL general_log = 'ON';"
mysql -u root -p -e "SET GLOBAL log_output = 'TABLE';"

# Review logged queries
mysql -u root -p -e "SELECT * FROM mysql.general_log WHERE argument LIKE '%UNION%' OR argument LIKE '%DROP%';"
```

### Response Actions

1. **Immediate**:
   ```bash
   # Block attacker IP
   sudo iptables -I INPUT -s <IP> -j DROP
   
   # Review logs for damage
   grep "UPDATE\|DELETE\|INSERT" /var/log/mysql/general_log | tail -100
   ```

2. **Short-term**:
   ```bash
   # Change critical passwords
   # Rotate API keys
   # Reset compromised user sessions
   
   mysql -u root -p -e "DELETE FROM sessions WHERE user_id = <compromised_user_id>;"
   ```

3. **Long-term**:
   ```bash
   # Audit all user actions
   # Review and strengthen authentication
   # Implement additional logging
   # Update security policies
   ```

---

## Deployment Issues

### Deployment Failed - Rollback

```bash
# Using Git rollback
git log --oneline | head -5
git revert HEAD  # Create inverse commit
git push origin main
```

### Service Won't Start After Deploy

```bash
# Check service status
systemctl status nginx
systemctl status php-fpm

# View detailed error
journalctl -u nginx -n 100
journalctl -u php-fpm -n 100

# Manual startup with debugging
cd /srv/farmos/begin_pyphp/backend
php -S 0.0.0.0:8001 -t public/

# Common causes:
# 1. Port already in use: lsof -i :8001
# 2. Missing dependencies: composer install
# 3. Bad environment: configure config/env.php or .env
# 4. Permission issues: chown -R deploy:deploy /srv/farmos
```

### Database Migration Failed

```bash
# Apply schema file
mysql -u farmos_user -p farmos < /srv/farmos/begin_pyphp/database/schema.sql
```

---

## Health Checks & Monitoring

### Essential Health Checks

```bash
#!/bin/bash
# Comprehensive health check script

check_api() {
    curl -s http://127.0.0.1:8001/health | grep -q "ok" && echo "✅ API" || echo "❌ API"
}

check_database() {
    mysql -u farmos_user -p -e "SELECT 1;" 2>/dev/null && echo "✅ Database" || echo "❌ Database"
}

check_cache() {
    redis-cli PING 2>/dev/null | grep -q "PONG" && echo "✅ Cache" || echo "❌ Cache"
}

check_disk() {
    USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    [ $USAGE -lt 90 ] && echo "✅ Disk ($USAGE%)" || echo "❌ Disk ($USAGE%)"
}

check_memory() {
    USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2*100)}')
    [ $USAGE -lt 90 ] && echo "✅ Memory ($USAGE%)" || echo "❌ Memory ($USAGE%)"
}

echo "=== Health Status ==="
check_api
check_database
check_cache
check_disk
check_memory
```

### Monitoring Stack Setup

- On shared hosting, use external monitoring (uptime checks + log shipping) or a separate VM for metrics.
- On a VM, install Prometheus + Grafana using your OS packages, then configure Prometheus to scrape the `/health` endpoint and server metrics.

### Key Metrics to Monitor

| Metric | Threshold | Alert |
|--------|-----------|-------|
| API Response Time (p95) | >200ms | Medium |
| API Response Time (p99) | >500ms | High |
| Error Rate | >1% | High |
| Database Connections | >80% pool | Medium |
| Disk Usage | >80% | Medium |
| Disk Usage | >90% | High |
| Memory Usage | >85% | Medium |
| Memory Usage | >95% | Critical |
| Database Replication Lag | >5s | High |
| Cache Hit Rate | <50% | Low |

---

## Escalation & Support

### Support Escalation Path

```
Tier 1: On-call Support (First responder)
├── Symptom identification
├── Basic troubleshooting
├── Health check
└── If unresolved → Tier 2

Tier 2: Senior Engineer  
├── Log analysis
├── Database troubleshooting
├── Service restart
└── If unresolved → Tier 3

Tier 3: Lead Engineer/DevOps
├── Infrastructure changes
├── Security incidents
├── Major outages
└── If critical → Executive notification
```

### Creating Support Tickets

**Required Information**:
1. **Detailed Description**: What is happening
2. **When**: When did it start
3. **Frequency**: Once or recurring
4. **Impact**: How many users affected
5. **Error Messages**: Exact error text
6. **Logs**: Relevant log excerpts
7. **Steps to Reproduce**: How to recreate

**Example Ticket**:
```
Title: API returns 502 Bad Gateway on /api/livestock endpoint

Description:
Users report inability to access livestock listing page. All API 
requests to /api/livestock return HTTP 502 Bad Gateway error.

When: Started 2026-03-12 14:30 UTC
Frequency: Continuous, all requests fail
Impact: ~50 users cannot access system

Error: 502 Bad Gateway (nginx error.log attached)

Logs:
[2026-03-12 14:30:45] ERROR: Database connection refused
[2026-03-12 14:30:45] ERROR: Failed to initialize connection pool

Steps to Reproduce:
1. Go to https://api.yourdomain.com
2. Click Livestock menu
3. Observe 502 error

Attachments: error.log, health-check.txt
```

### Contact Information

```
Emergency (Critical System Down):
  Phone: +1-XXX-XXX-XXXX (On-call)
  Slack: #farmos-incidents

High Priority Issues:
  Email: ops@farmos.internal
  Slack: #farmos-support
  Response: Within 1 hour

Normal Issues:
  Email: support@farmos.internal
  Jira: FARMOS-xxxx
  Response: Next business day

Documentation:
  Wiki: https://wiki.farmos.internal
  Runbooks: https://runbooks.farmos.internal
  API Docs: https://api.farmos.internal/api
```

---

## Troubleshooting Decision Tree

```
START
  │
  ├─ Can users access application?
  │   │
  │   ├─ NO → Check 502 Bad Gateway section
  │   │        Is backend running?
  │   │        └─ Systemctl restart → YES?
  │   │
  │   └─ YES → Is data displayed correctly?
  │       │
  │       ├─ NO → Check database connection
  │       │        Slow queries?
  │       │        └─ Run health check
  │       │
  │       └─ YES → Are there error messages?
  │           │
  │           ├─ YES → Check specific error section
  │           │
  │           └─ NO → Check performance issues
  │               Response time acceptable?
  │               └─ Monitor and log
  │
  └─ Check logs → Analyze → Resolve → Test → Document
```

---

## Runbook Template

Use this template when creating runbooks:

```markdown
# Runbook: [Issue Name]

## Overview
- **Severity**: [Critical/High/Medium/Low]
- **Estimated Resolution**: [Time]
- **Responsibility**: [Team]

## Symptoms
- [Symptom 1]
- [Symptom 2]

## Root Causes
- [Cause 1]
- [Cause 2]

## Resolution Steps
1. Step 1
   ```bash
   command
   ```
2. Step 2
   ```bash
   command
   ```

## Verification
- [ ] Check passed
- [ ] Users confirmed resolved

## Documentation
- Link to issue
- Link to PR/change
```

---

## References

- [Nginx Troubleshooting](https://nginx.org/en/docs/debugging_log.html)
- [MySQL Troubleshooting](https://dev.mysql.com/doc/refman/5.7/en/troubleshooting.html)
- [PHP Manual](https://www.php.net/manual/en/)
- [Redis Troubleshooting](https://redis.io/topics/problems)
- [Systemd Troubleshooting](https://wiki.archlinux.org/title/Systemd)

---

**Document Version**: 1.0  
**Status**: Production Ready ✅  
**Last Updated**: March 12, 2026  
**Maintained By**: DevOps & Support Teams
