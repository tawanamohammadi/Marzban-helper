#!/bin/bash

# Marzban Auxiliary Panel - Re-Installation Script (Fixes only)
echo "============================================"
echo "   Marzban Auxiliary Panel - Quick Fixer    "
echo "============================================"

# 1. Fix Backend Requirements (Missing dotenv)
echo "[*] Installing missing python packages..."
cd backend
# Check if venv exists, if not create it
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install python-dotenv
pip install -r requirements.txt

# 2. Fix Database Initialization (Run create_admin again)
# We need to read credentials from .env or ask again? 
# Better to ask again or parsing is hard in bash.
# Let's assume .env exists from previous run, we just need to re-run the seed script.
if [ -f ".env" ]; then
    # Parse MARZBAN_USER from previous input or just ask user to be safe
    echo "[?] Enter your Marzban Username again to finalize DB setup:"
    read -p "Username: " ADMIN_USER
    read -s -p "Password: " ADMIN_PASS
    echo ""
    python3 create_admin.py "$ADMIN_USER" "$ADMIN_PASS"
else
    echo "❌ .env file missing. Please run install.sh from scratch."
fi

deactivate
cd ..

echo "✅ Fixes applied. Try running ./start.sh now."
