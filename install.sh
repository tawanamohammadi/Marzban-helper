#!/bin/bash

# Marzban Auxiliary Panel - Installation Script
echo "============================================"
echo "   Marzban Auxiliary Panel Installer V1.0   "
echo "============================================"

# 1. Check Dependencies
echo "[*] Checking dependencies..."
if ! command -v python3 &> /dev/null; then
    echo "Python3 could not be found. Please install it."
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo "npm/node could not be found. Please install Node.js 18+."
    exit 1
fi

# 2. Configuration
echo ""
echo "[?] Please provide configuration details:"
read -p "Enter Marzban Sudo Token: " SUDO_TOKEN
read -p "Enter Desired Super Admin Username (for Aux Panel): " ADMIN_USER
read -s -p "Enter Desired Super Admin Password: " ADMIN_PASS
echo ""

# 3. Setup Backend
echo ""
echo "[*] Setting up Backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env
cat <<EOF > .env
SECRET_KEY=$(openssl rand -hex 32)
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
MARZBAN_BASE_URL=http://127.0.0.1:8000
MARZBAN_SUDO_TOKEN=$SUDO_TOKEN
DATABASE_URL=sqlite:///./auxiliary_panel.db
EOF

# Create Admin
echo "[*] Creating Super Admin..."
python3 create_admin.py "$ADMIN_USER" "$ADMIN_PASS"
deactivate
cd ..

# 4. Setup Frontend
echo ""
echo "[*] Setting up Frontend..."
cd frontend
npm install
cd ..

echo ""
echo "============================================"
echo "   Installation Complete!                   "
echo "   Run './start.sh' to launch the panel.    "
echo "============================================"
