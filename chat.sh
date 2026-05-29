#!/bin/bash

BASE_DIR=~/smart-academic-assistant
BACKEND_DIR=$BASE_DIR/backend
FRONTEND_DIR=$BASE_DIR/frontend
VENV=$BACKEND_DIR/venv

echo "=============================="
echo " FULL STACK CHAT START"
echo "=============================="

# 1. Activate venv
echo "[1] Activating venv..."
source $VENV/bin/activate

# 2. Kill only old backend (NOT full port flush)
echo "[2] Cleaning old backend process..."
pkill -f "python.*app.py" || true

# 3. Start backend (NO reset logic inside app)
echo "[3] Starting backend..."
cd $BACKEND_DIR
nohup python app.py > backend.log 2>&1 &

# 4. Start frontend (static server safe)
echo "[4] Starting frontend..."
cd $FRONTEND_DIR
nohup python3 -m http.server 8000 > frontend.log 2>&1 &

# 5. Check Ollama
echo "[5] Checking Ollama..."
curl -s http://127.0.0.1:11434 > /dev/null && echo "Ollama OK" || echo "Ollama DOWN"

# 6. Wait backend to boot
echo "[6] Backend health..."
sleep 2
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " SYSTEM READY 🚀"
echo " Backend  : http://127.0.0.1:5000"
echo " Frontend : http://127.0.0.1:8000"
echo " Ollama   : http://127.0.0.1:11434"
echo "=============================="
