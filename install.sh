#!/bin/bash

# Marzban Auxiliary Panel - Installation Script V1.2
echo "============================================"
echo "   Marzban Auxiliary Panel Installer V1.2   "
echo "============================================"

# 1. Dependency Check with Auto-Fix
echo "[*] Checking dependencies..."
if ! command -v python3 &> /dev/null; then
    echo "Python3 could not be found. Please install it (apt install python3)."
    exit 1
fi

# Check for venv explicitly
echo "[*] Checking for python3-venv..."
python3 -m venv test_env 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ Python venv module missing."
    echo "   Attempting to install 'python3-venv'..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y python3-venv python3-pip
    else
        echo "   Could not auto-install. Please run: apt install python3-venv"
        exit 1
    fi
else
    rm -rf test_env
    echo "✅ Python venv is available."
fi

# 2. Configuration
echo ""
echo "[?] We need to connect to your Marzban instance."
read -p "Marzban Username: " MARZBAN_USER
read -s -p "Marzban Password: " MARZBAN_PASS
echo ""
read -p "Marzban URL [default: http://127.0.0.1:8000]: " MARZBAN_URL
MARZBAN_URL=${MARZBAN_URL:-http://127.0.0.1:8000}
MARZBAN_URL=${MARZBAN_URL%/}

echo ""

# 3. Setup Backend
echo "[*] Setting up Backend..."
cd backend
# Always create fresh venv
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# Use pip from venv explicitly
./venv/bin/pip install -r requirements.txt
./venv/bin/pip install python-dotenv

# Fetch Token
echo "[*] Fetching Marzban Token..."
cat <<EOF > get_token.py
import requests
import sys
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

try:
    resp = requests.post(
        "${MARZBAN_URL}/api/admin/token", 
        data={"username": "${MARZBAN_USER}", "password": "${MARZBAN_PASS}", "grant_type": "password"},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        verify=False,
        timeout=10
    )
    if resp.status_code == 200:
        print(resp.json()["access_token"])
    else:
        print("ERROR")
except:
    print("ERROR")
EOF

TOKEN=$(./venv/bin/python3 get_token.py)
rm get_token.py

if [[ "$TOKEN" == *"ERROR"* ]]; then
    # Create .env anyway to allow manual fix later, but warn user
    echo "⚠️  Could not fetch token automatically. You may need to edit backend/.env manually."
    TOKEN="manual_update_required"
else
    echo "✅ Token acquired."
fi

# Create .env
cat <<EOF > .env
SECRET_KEY=$(openssl rand -hex 32)
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
MARZBAN_BASE_URL=$MARZBAN_URL
MARZBAN_SUDO_TOKEN=$TOKEN
DATABASE_URL=sqlite:///./auxiliary_panel.db
EOF

# Initialize Database Explicitly BEFORE creating admin
echo "[*] Initializing Database Tables..."
cat <<EOF > init_db.py
from app.core.database import engine, Base
from app.models import reseller, user_map
Base.metadata.create_all(bind=engine)
print("Tables Created.")
EOF
./venv/bin/python3 init_db.py
rm init_db.py

# Create Admin
echo "[*] Creating Local Admin..."
./venv/bin/python3 create_admin.py "$MARZBAN_USER" "$MARZBAN_PASS"

# Fix permission/path issue by not using 'deactivate'
cd ..

# 4. Setup Frontend
echo ""
echo "[*] Setting up Frontend..."
cd frontend
npm install
echo "[*] Building Next.js Frontend (This may take a minute)..."
npm run build
cd ..

echo ""
echo "============================================"
echo "   Installation Complete!                   "
echo "   Run './start.sh' to launch the panel.    "
echo "============================================"
