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
- **Language**: Python 3.10+
- **Framework**: FastAPI
- **ORM**: SQLAlchemy
- **Database**: MySQL
- **Authentication**: JWT, API Keys

### Frontend
- **Language**: PHP
- **Server**: WAMP (Apache + PHP)
- **Architecture**: MVC with templates and components

## 🏗️ Architecture

```
FarmOS/
├── begin_pyphp/
│   ├── backend/           # FastAPI Python backend
│   │   ├── app.py         # Main application
│   │   ├── routers/       # API endpoints
│   │   ├── models/        # Database models
│   │   ├── database/      # DB configuration
│   │   └── requirements.txt
│   ├── frontend/          # PHP web application
│   │   ├── public/        # Web root
│   │   ├── pages/         # Template pages
│   │   └── components/    # Reusable components
│   └── database/          # Schema and migrations
├── backend/
│   └── iot_simulations/   # IoT sensor simulators
├── docs/                  # Documentation
└── [configuration files]
```

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- WAMP/XAMPP (Apache + PHP + MySQL)
- pip package manager
- MySQL 5.7 or higher

### 1. Clone and Setup Backend

```bash
cd begin_pyphp/backend
pip install -r requirements.txt
```

### 2. Configure Database

Update database credentials in `backend/app.py` or `.env`:
```
DATABASE_URL=mysql://root:password@localhost:3306/farmos
```

### 3. Start Backend Server

```bash
cd begin_pyphp/backend
uvicorn app:app --host 127.0.0.1 --port 8000 --reload
```

Backend will be available at: `http://127.0.0.1:8000`

### 4. Start Frontend (WAMP)

1. Ensure WAMP is running (Apache + PHP + MySQL)
2. Visit: `http://localhost/farmos/begin_pyphp/frontend/public/`

### 5. Verify Installation

```bash
# Check backend health
curl http://127.0.0.1:8000/health

# Check API version
curl http://127.0.0.1:8000/api/version
```

## 📖 Documentation

- [Quick Start Guide](./QUICK_START.md) - Get up and running in minutes
- [Getting Started](./begin_pyphp/GETTING_STARTED.md) - Detailed setup instructions
- [System Design](./system_design.md) - Architecture and design patterns
- [User Manual](./docs/USER_MANUAL.md) - End-user guide
- [Developer Guide](./docs/DEVELOPER_GUIDE.md) - Development guidelines

## 🔐 Default Login

After seeding sample data:

```
Email: admin@example.com
Password: password123
```

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

Base URL: `http://127.0.0.1:8000/api`

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /auth/profile` - Get user profile

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
# Backend with auto-reload
cd begin_pyphp/backend
uvicorn app:app --reload

# Frontend (WAMP auto-reloads PHP)
# Just edit files and refresh the browser
```

### Running Tests

```bash
cd begin_pyphp/backend
pytest

# Or with coverage
pytest --cov=.
```

### Database Migrations

```bash
# Check current schema
python begin_pyphp/backend/database_verification_report.py

# Apply migrations
python begin_pyphp/backend/database_migration.py
```

## 🐛 Troubleshooting

### Backend Won't Start
- Verify Python 3.10+ is installed: `python --version`
- Check dependencies: `pip install -r requirements.txt`
- Ensure port 8000 is available

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
- `begin_pyphp/backend/app.py` - Backend configuration
- `.env` - Environment variables (create if needed)
- `begin_pyphp/frontend/config.php` - Frontend configuration

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
**Last Updated**: March 2026  
**Version**: 1.0.0

---

**FarmOS** - Making farm management simple and efficient.
