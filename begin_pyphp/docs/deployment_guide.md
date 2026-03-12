# Begin Masimba - Deployment Guide

## Production Deployment

### Prerequisites
- Linux Server (Ubuntu 20.04+ recommended)
- Python 3.8+
- PHP 7.4+ or 8.0+
- Web Server (Nginx or Apache)
- Database (PostgreSQL or MySQL recommended for production)
- Supervisor (for process management)

### Backend Deployment

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-repo/begin_pyphp.git
   cd begin_pyphp/backend
   ```

2. **Install Dependencies**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   pip install gunicorn
   ```

3. **Configure Environment**:
   Create a `.env` file with production settings:
   ```env
   DATABASE_URL=postgresql://user:password@localhost/dbname
   SECRET_KEY=your-production-secret-key
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   API_KEY=your-production-api-key
   TENANT_ID=1
   ```

4. **Run with Gunicorn**:
   Use Gunicorn with Uvicorn workers:
   ```bash
   gunicorn -w 4 -k uvicorn.workers.UvicornWorker app:app
   ```

5. **Supervisor Configuration**:
   Create `/etc/supervisor/conf.d/farmos-backend.conf`:
   ```ini
   [program:farmos-backend]
   directory=/path/to/begin_pyphp/backend
   command=/path/to/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker app:app --bind 0.0.0.0:8000
   autostart=true
   autorestart=true
   stderr_logfile=/var/log/farmos-backend.err.log
   stdout_logfile=/var/log/farmos-backend.out.log
   ```

### Frontend Deployment

1. **Configure Web Server (Nginx)**:
   Create `/etc/nginx/sites-available/farmos`:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /path/to/begin_pyphp/frontend/public;
       index index.php;

       location / {
           try_files $uri $uri/ /index.php?$query_string;
       }

       location ~ \.php$ {
           include snippets/fastcgi-php.conf;
           fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
       }

       location /api/ {
           proxy_pass http://localhost:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

2. **Enable Site**:
   ```bash
   ln -s /etc/nginx/sites-available/farmos /etc/nginx/sites-enabled/
   nginx -t
   systemctl restart nginx
   ```

### Database Migration
Ensure your production database is initialized with the schema files in `database/`.

```bash
mysql -u user -p dbname < database/schema.sql
# Apply other schema files as needed
```

### Security
- Use HTTPS (Let's Encrypt).
- Set secure passwords and API keys.
- Restrict database access.
- Regularly update dependencies.
