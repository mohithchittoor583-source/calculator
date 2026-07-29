#!/bin/bash

set -e

echo "======================================"
echo " Calculator 3-Tier Application Setup"
echo "======================================"

# --------------------------------------
# 1. Update System
# --------------------------------------

echo "Updating system packages..."

sudo dnf update -y


# --------------------------------------
# 2. Install Required Packages
# --------------------------------------

echo "Installing Git, Python and MySQL..."

sudo dnf install -y \
    git \
    python3 \
    python3-pip \
    python3-devel \
    gcc \
    mysql-server


# --------------------------------------
# 3. Start MySQL
# --------------------------------------

echo "Starting MySQL..."

sudo systemctl enable mysqld
sudo systemctl start mysqld

sleep 5

sudo systemctl status mysqld --no-pager


# --------------------------------------
# 4. MySQL Configuration
# --------------------------------------

DB_NAME="calculator_db"
DB_USER="calculatoruser"
DB_PASSWORD="Calculator@123"

echo "Creating MySQL database..."

sudo mysql <<EOF

CREATE DATABASE IF NOT EXISTS ${DB_NAME};

CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON ${DB_NAME}.*
TO '${DB_USER}'@'localhost';

FLUSH PRIVILEGES;

USE ${DB_NAME};

CREATE TABLE IF NOT EXISTS calculations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    number1 DECIMAL(10,2) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    number2 DECIMAL(10,2) NOT NULL,
    result DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

EOF

echo "MySQL database setup completed."


# --------------------------------------
# 5. Create Python Virtual Environment
# --------------------------------------

echo "Setting up Python virtual environment..."

cd ~/calculator/backend

python3 -m venv venv

source venv/bin/activate


# --------------------------------------
# 6. Upgrade pip
# --------------------------------------

echo "Upgrading pip..."

python -m pip install --upgrade pip


# --------------------------------------
# 7. Install Python Dependencies
# --------------------------------------

echo "Installing Python dependencies..."

if [ -f requirements.txt ]; then

    python -m pip install -r requirements.txt

else

    echo "requirements.txt not found."
    echo "Installing required packages manually..."

    python -m pip install \
        Flask \
        Flask-CORS \
        mysql-connector-python \
        python-dotenv

fi


# --------------------------------------
# 8. Create Backend .env
# --------------------------------------

echo "Creating backend .env file..."

cat > ~/calculator/backend/.env <<EOF

DB_HOST=localhost
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
PORT=5000

EOF


# --------------------------------------
# 9. Install Node.js
# --------------------------------------

echo "Checking Node.js installation..."

if ! command -v node &> /dev/null
then

    echo "Installing Node.js..."

    sudo dnf module enable nodejs:20 -y

    sudo dnf install nodejs -y

else

    echo "Node.js is already installed."

fi


# --------------------------------------
# 10. Check Node.js and npm
# --------------------------------------

echo "Node.js version:"
node --version

echo "npm version:"
npm --version


# --------------------------------------
# 11. Install React Dependencies
# --------------------------------------

echo "Installing React dependencies..."

cd ~/calculator/frontend

npm install


# --------------------------------------
# 12. Final Status
# --------------------------------------

echo ""
echo "======================================"
echo " Setup Completed Successfully!"
echo "======================================"

echo ""
echo "MySQL Database:"
echo "Database : ${DB_NAME}"
echo "User     : ${DB_USER}"
echo "Password : ${DB_PASSWORD}"

echo ""
echo "Backend:"
echo "Location : ~/calculator/backend"
echo "Port     : 5000"

echo ""
echo "Frontend:"
echo "Location : ~/calculator/frontend"
echo "Port     : 5173"

echo ""
echo "Start Backend:"
echo "cd ~/calculator/backend"
echo "source venv/bin/activate"
echo "python app.py"

echo ""
echo "Start Frontend:"
echo "cd ~/calculator/frontend"
echo "npm run dev -- --host 0.0.0.0"

echo ""
echo "======================================"