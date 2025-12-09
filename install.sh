#!/bin/bash

# Marzban Auxiliary Panel - Installation Script
echo "============================================"
echo "   Marzban Auxiliary Panel Installer V1.1   "
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
echo "[?] We need to connect to your Marzban instance."
read -p "Marzban Username: " MARZBAN_USER
read -s -p "Marzban Password: " MARZBAN_PASS
echo ""
# Ask for Port/Domain - Default to local 8000
echo -e "\n[?] Enter Marzban Address (Usually http://127.0.0.1:8000 if local)."
echo "    If you changed the port or are using SSL, enter full URL."
echo "    Example: https://tawanaproxy.panbehpanel.ir:2096"
read -p "Marzban URL [default: http://127.0.0.1:8000]: " MARZBAN_URL
MARZBAN_URL=${MARZBAN_URL:-http://127.0.0.1:8000}

# Remove trailing slash
MARZBAN_URL=${MARZBAN_URL%/}

echo ""

# 3. Setup Backend
echo "[*] Setting up Backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Fetch Token Automatically using a tempoary script
echo "[*] Connecting to $MARZBAN_URL to fetch token..."
cat <<EOF > get_token.py
import requests
import sys

try:
    resp = requests.post(
        "${MARZBAN_URL}/api/admin/token", 
        data={"username": "${MARZBAN_USER}", "password": "${MARZBAN_PASS}", "grant_type": "password"},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        timeout=10
    )
    if resp.status_code == 200:
        print(resp.json()["access_token"])
    else:
        print("ERROR_STATUS_" + str(resp.status_code))
        print(resp.text)
except Exception as e:
    print("ERROR_CONN")
    print(str(e))
EOF

# Capture Output
OUTPUT=$(python3 get_token.py)
TOKEN=$(echo "$OUTPUT" | head -n 1) # First line is token or error

# Basic Error Handling
if [[ "$TOKEN" == *"ERROR"* ]]; then
    echo "❌ Failed to login to Marzban at $MARZBAN_URL"
    echo "   Details: $OUTPUT"
    echo "   Please check URL, Port, and Credentials."
    exit 1
else
    echo "✅ Login Successful! Token acquired."
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

# Create Admin in Local DB (Mirroring the Marzban Admin)
echo "[*] Initializing Database..."
python3 create_admin.py "$MARZBAN_USER" "$MARZBAN_PASS"
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
