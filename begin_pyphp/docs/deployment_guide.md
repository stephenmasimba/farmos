# Begin Masimba - Deployment Guide

## Production Deployment

### Prerequisites
- Linux Server (Ubuntu 20.04+ recommended)
- PHP 8.0+
- Web Server (Nginx or Apache)
- Database (MySQL recommended for production)

### Backend Deployment

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-repo/begin_pyphp.git
   cd begin_pyphp/backend
   ```

2. **Install Dependencies**:
   ```bash
   composer install --no-dev --optimize-autoloader
   ```

3. **Configure Environment**:
   Create a `.env` file with production settings:
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://your-domain.com
   DATABASE_HOST=localhost
   DATABASE_PORT=3306
   DATABASE_NAME=begin_masimba_farm
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   JWT_SECRET=your-production-secret-key
   ```

4. **Run with PHP-FPM (Recommended)**:
   ```bash
   php-fpm8.0 -t
   ```

5. **Serve the Backend**:
   Point your web server document root to `backend/public/`.

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
