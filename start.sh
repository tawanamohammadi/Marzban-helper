#!/bin/bash

# Start Backend
echo "[*] Starting Backend on Port 7000..."
cd backend
# Check if venv exists
if [ -d "venv" ]; then
    source venv/bin/activate
    # Use python directly from venv to avoid path issues
    nohup ./venv/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 7000 > ../backend.log 2>&1 &
    BACKEND_PID=$!
    echo "Backend running (PID: $BACKEND_PID)"
else
    echo "❌ CRM Backend VirtualEnv not found! Did install.sh finish?"
fi
cd ..

# Start Frontend
echo "[*] Starting Frontend on Port 3000..."
cd frontend
# Ensure build exists
if [ ! -d ".next" ]; then
    echo "⚠️  Frontend build not found. Building now..."
    npm run build
fi
nohup npm run start -- -p 3000 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo "Frontend running (PID: $FRONTEND_PID)"
cd ..

echo ""
echo "Auxiliary Panel is hosted!"
echo "Backend Logs: cat backend.log"
echo "Frontend Logs: cat frontend.log"
