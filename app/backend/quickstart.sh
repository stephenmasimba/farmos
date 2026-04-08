#!/bin/bash

# FarmOS PHP Backend Quick Start Script
# This script sets up and runs the PHP backend locally

set -e

echo "================================"
echo "FarmOS PHP Backend Quick Start"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check PHP installation
echo -n "Checking PHP installation... "
if ! command -v php &> /dev/null; then
    echo -e "${RED}PHP not found${NC}"
    echo "Install PHP 8.0+ first"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1 | cut -d' ' -f2)
echo -e "${GREEN}OK (v$PHP_VERSION)${NC}"

# Check Composer
echo -n "Checking Composer installation... "
if ! command -v composer &> /dev/null; then
    echo -e "${RED}Composer not found${NC}"
    echo "Install Composer: https://getcomposer.org/download/"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Check MySQL
echo -n "Checking MySQL installation... "
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}WARNING: MySQL not in PATH${NC}"
    echo "MySQL may still be running (check your package manager)"
else
    echo -e "${GREEN}OK${NC}"
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "Step 1: Installing PHP dependencies..."
if [ ! -d "vendor" ]; then
    composer install
else
    echo "  Dependencies already installed"
fi

echo ""
echo "Step 2: Checking configuration..."
if [ ! -f ".env" ]; then
    echo "  Creating .env from .env.example..."
    cp .env.example .env
    echo -e "${YELLOW}  WARNING: Update .env with your database credentials${NC}"
else
    echo "  .env already exists"
fi

# Create necessary directories
echo ""
echo "Step 3: Creating directories..."
mkdir -p storage/logs storage/uploads
chmod -R 755 storage/ 2>/dev/null || true

echo ""
echo "Step 4: Configuration check..."
if [ -f ".env" ]; then
    DB_HOST=$(grep "DATABASE_HOST" .env | cut -d'=' -f2)
    DB_NAME=$(grep "DATABASE_NAME" .env | cut -d'=' -f2)
    echo "  Database Host: $DB_HOST"
    echo "  Database Name: $DB_NAME"
fi

echo ""
echo "================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Update .env with your database credentials:"
echo "   nano .env"
echo ""
echo "2. Start the development server:"
echo "   php -S localhost:8000 -t public/"
echo ""
echo "3. Test the API:"
echo "   curl http://localhost:8000/health"
echo ""
echo "4. Try login:"
echo "   curl -X POST http://localhost:8000/api/auth/login \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"email\":\"admin@example.com\",\"password\":\"password123\"}'"
echo ""
echo "For more information, see PHP_BACKEND_README.md"
echo ""
