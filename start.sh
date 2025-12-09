#!/bin/bash

# Start Backend
echo "[*] Starting Backend on Port 7000..."
cd backend
source venv/bin/activate
nohup uvicorn main:app --host 0.0.0.0 --port 7000 > ../backend.log 2>&1 &
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
echo "Auxiliary Panel is running!"
echo "Backend: http://YOUR_IP:7000"
echo "Frontend: http://YOUR_IP:3000"
