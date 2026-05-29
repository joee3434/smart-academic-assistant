#!/bin/bash

BASE=~/smart-academic-assistant
BACKEND=$BASE/backend
FRONTEND=$BASE/frontend
VENV=$BACKEND/venv

echo "=============================="
echo " SMART ASSISTANT AUTO FIX"
echo "=============================="

# 1) Activate venv
echo "[1] Activating venv..."
source $VENV/bin/activate

# 2) Kill old processes safely
echo "[2] Killing old backend/frontend..."
pkill -f "python app.py" || true
pkill -f "http.server 8000" || true

# 3) Fix common bug: docs reset file
echo "[3] Fixing persistence (docs.json)..."

cd $BACKEND

if [ ! -f docs.json ]; then
  echo "{}" > docs.json
  echo "Created docs.json"
fi

# 4) Ensure backend does NOT crash
echo "[4] Starting backend..."
nohup python app.py > backend.log 2>&1 &

sleep 2

# 5) Start frontend
echo "[5] Starting frontend..."
cd $FRONTEND
nohup python3 -m http.server 8000 > frontend.log 2>&1 &

sleep 2

# 6) Health check
echo "[6] Backend health check..."
curl -s http://127.0.0.1:5000/health || echo "Backend not responding"

echo ""
echo "=============================="
echo " DONE FIXING SYSTEM 🚀"
echo " Backend  : http://127.0.0.1:5000"
echo " Frontend : http://127.0.0.1:8000"
echo "=============================="
