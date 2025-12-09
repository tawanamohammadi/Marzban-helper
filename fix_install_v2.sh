#!/bin/bash

# Marzban Auxiliary Panel - Re-Installation Script V2 (Path & Env Fix)
echo "============================================"
echo "   Marzban Auxiliary Panel - Quick Fixer V2 "
echo "============================================"

# Ensure we are in the root directory
cd "$(dirname "$0")"

# 1. Frontend Build (Vital for 'next start')
echo "[*] Building Frontend (This was missing)..."
cd frontend
# Check for node_modules
if [ ! -d "node_modules" ]; then
    npm install
fi
npm run build
cd ..

# 2. Fix Backend Venv & Requirements
echo "[*] Fixing Backend..."
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt
# Re-ensure dotenv
pip install python-dotenv

# 3. Database Migration (Fix 'no such table: resellers')
# The previous valid error was because main.py failed to import, so tables weren't created.
# We will run a small python snippet to explicitly create tables NOW.
echo "[*] Ensuring Database Tables exist..."
cat <<EOF > init_db.py
from app.core.database import engine, Base
from app.models import reseller, user_map
Base.metadata.create_all(bind=engine)
print("Tables Created.")
EOF
python3 init_db.py
rm init_db.py

# 4. Create Admin (Again, if needed)
if [ -f ".env" ]; then
    # We ask user just in case, or try to read from a previous input
    echo "[?] Do you want to re-create the admin user? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        read -p "Username: " ADMIN_USER
        read -s -p "Password: " ADMIN_PASS
        echo ""
        python3 create_admin.py "$ADMIN_USER" "$ADMIN_PASS"
    fi
fi

deactivate
cd ..

echo "✅ Fixes applied." 
echo "➡️  Run './start.sh' again."
