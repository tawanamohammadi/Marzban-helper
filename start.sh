#!/bin/bash

echo "[*] Cleaning up old processes..."
# Kill any process on port 7000 (Backend)
if lsof -t -i:7000 > /dev/null; then
    echo "  - Stopping Backend on port 7000..."
    kill -9 $(lsof -t -i:7000)
fi

# Kill any process on port 3000 (Frontend)
if lsof -t -i:3000 > /dev/null; then
    echo "  - Stopping Frontend on port 3000..."
    kill -9 $(lsof -t -i:3000)
fi

# Wait a second
sleep 1

# Start Backend
echo "[*] Starting Backend on Port 7000..."
cd backend
source venv/bin/activate
nohup ./venv/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 7000 > ../backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend running (PID: $BACKEND_PID)"
cd ..

# Start Frontend
echo "[*] Starting Frontend on Port 3000..."
cd frontend
nohup npm run start -- -p 3000 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo "Frontend running (PID: $FRONTEND_PID)"
cd ..

echo ""
echo "Auxiliary Panel is hosted!"
echo "Backend Logs: cat backend.log"
echo "Frontend Logs: cat frontend.log"
