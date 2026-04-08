# FarmOS - Comprehensive Farm Management System

**FarmOS** is a full-stack farm management system designed to help farmers and agricultural operations manage livestock, crops, inventory, sensors, and financial transactions in real-time.

## 🌾 Key Features

- **Livestock Management**: Track animal batches, health records, and events
- **Inventory Management**: Monitor feed, supplies, and stock levels
- **Dashboard Analytics**: Real-time insights and alerts
- **IoT Integration**: Connect and monitor farm sensors
- **Financial Tracking**: Manage sales, transactions, and revenue
- **User Authentication**: Secure JWT-based authentication
- **Multi-user Support**: Role-based access control (Admin, Manager, Worker)
- **RESTful API**: Complete API for integrations and extensions

## 📦 Tech Stack

### Backend
- **Language**: PHP 7.4+
- **Framework**: Pure PHP (custom router/controllers/models)
- **Database**: MySQL
- **Authentication**: JWT, API Keys

### Frontend
- **Language**: PHP
- **Server**: WAMP (Apache + PHP)
- **Architecture**: MVC with templates and components

## 🏗️ Architecture

```
FarmOS/
├── app/
│   ├── backend/           # Pure PHP backend API
│   │   ├── public/        # Web root (index.php)
│   │   ├── src/           # Controllers, models, core classes
│   │   └── tests/         # PHPUnit tests
│   ├── frontend/          # PHP web application
│   │   ├── public/        # Web root
│   │   ├── pages/         # Template pages
│   │   └── components/    # Reusable components
│   └── database/          # Schema and migrations
├── backend/
│   └── iot_simulations/   # IoT sensor simulators (PHP)
├── docs/                  # Documentation
└── [configuration files]
```

## 🚀 Quick Start

### Prerequisites
- PHP 7.4+
- Composer
- WAMP/XAMPP (Apache + PHP + MySQL)
- MySQL 5.7 or higher

### 1. Install Backend Dependencies

```bash
cd app/backend
composer install
```

### 2. Configure Database

Update credentials in `app/backend/config/env.php` (or create `app/backend/config/.env` from `.env.example`).

### 3. Start Backend

The backend runs under Apache (WAMP) at:
- `http://localhost:8081/farmos/app/backend/`

Or, for local development without Apache:
```bash
cd app/backend
composer run serve
```

### 4. Start Frontend (WAMP)

1. Ensure WAMP is running (Apache + PHP + MySQL)
2. Visit: `http://localhost:8081/farmos/app/frontend/public/`

### 5. Verify Installation

```bash
# Check backend health
curl http://localhost:8081/farmos/app/backend/health

# Check API version
curl http://localhost:8081/farmos/app/backend/api/version
```

## 📖 Documentation

- [Documentation Index](./docs/INDEX.md) - Central navigation for all remaining docs
- [Quick Start Guide](./QUICK_START.md) - Get up and running in minutes
- [User Manual](./docs/USER_MANUAL.md) - End-user guide
- [Developer Guide](./docs/DEVELOPER_GUIDE.md) - Development guidelines
- [Architecture](./docs/consolidated/ARCHITECTURE.md)
- [Operations](./docs/consolidated/OPERATIONS.md)
- [Database](./docs/consolidated/DATABASE.md)
- [Security](./docs/consolidated/SECURITY.md)
- [Status](./docs/consolidated/STATUS.md)
- [App Transition](./docs/consolidated/APP_TRANSITION.md)

## 🔐 Login

FarmOS does not ship with default production credentials.

- Create users via `POST /api/auth/register`, or
- Use a controlled seed process for non-production (credentials should be provided via environment variables and/or printed at seed time).

## 📚 Main Modules

### Livestock Management
- Create and manage animal batches
- Track animal events (births, deaths, illnesses)
- Monitor feed schedules

### Inventory System
- Track inventory items and stock levels
- Manage feed ingredients
- Monitor supply levels

### Dashboard
- Real-time alerts and notifications
- Key metrics and KPIs
- Task management

### Financial Management
- Sales orders and transactions
- Revenue tracking
- Feed formulation costs

### IoT Integration
- Connect farm sensors
- Real-time sensor data collection
- Alert generation from sensor readings

## 🔌 API Endpoints

Base URL (WAMP): `http://localhost:8081/farmos/app/backend/api`

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /auth/me` - Get current user

### Livestock
- `GET /livestock` - List all livestock batches
- `POST /livestock` - Create new batch
- `GET /livestock/{id}` - Get batch details
- `PUT /livestock/{id}` - Update batch
- `DELETE /livestock/{id}` - Delete batch

### Inventory
- `GET /inventory` - List inventory items
- `POST /inventory` - Create item
- `PUT /inventory/{id}` - Update item

### Dashboard
- `GET /dashboard/alerts` - Get system alerts
- `GET /dashboard/metrics` - Get key metrics

See [full API documentation](./docs/DEVELOPER_GUIDE.md) for complete endpoint list.

## 🛠️ Development

### Running in Development Mode

```bash
# Backend under Apache (WAMP)
# http://localhost:8081/farmos/app/backend/

# Or start the PHP built-in server
cd app/backend
composer run serve

# Frontend (WAMP auto-reloads PHP)
# Just edit files and refresh the browser
```

### Running Tests

```bash
cd app/backend
composer run test
```

### Database Migrations

```bash
# Database schema files
dir app\database\*.sql
```

## 🐛 Troubleshooting

### Backend Won't Start
- Verify PHP and Composer are installed: `php -v` and `composer -V`
- Check backend dependencies: `cd app/backend && composer install`
- If using the built-in server, ensure the port is available (default: 8001)

### Database Connection Errors
- Verify MySQL is running
- Check credentials in configuration
- Ensure database exists: `CREATE DATABASE farmos;`

### Frontend Not Loading
- Verify WAMP is running (Apache + PHP)
- Check Apache error logs
- Ensure correct path in browser

### CORS Issues
- Backend is configured to accept frontend requests
- Verify frontend URL matches CORS configuration

## 📝 Configuration

Key configuration files:
- `app/backend/config/env.php` - Backend configuration defaults
- `app/backend/config/.env` - Environment variables (optional; overrides defaults)
- `app/frontend/config.php` - Frontend configuration

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make your changes
3. Add tests for new functionality
4. Submit a pull request

## 📄 License

[Specify your license here]

## 📧 Support

For issues, questions, or suggestions:
- Check the [documentation](./docs/)
- Review [GitHub Issues](./issues/)
- Contact the development team

## 🎯 Roadmap

- [ ] Mobile app (React Native)
- [ ] Advanced analytics and reporting
- [ ] Weather integration
- [ ] Machine learning for crop prediction
- [ ] Blockchain for supply chain tracking
- [ ] Multi-farm management dashboard

## 📋 Project Status

**Status**: Production Ready  
**Last Updated**: April 2026  
**Version**: 1.1.0

---

**FarmOS** - Making farm management simple and efficient.
