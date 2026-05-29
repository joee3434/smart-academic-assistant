#!/bin/bash

echo "=============================="
echo " FULL STACK CHAT START"
echo "=============================="

BASE_DIR=~/smart-academic-assistant
BACKEND_DIR=$BASE_DIR/backend
FRONTEND_DIR=$BASE_DIR/frontend
VENV_DIR=$BASE_DIR/backend/venv

# 1. Activate venv
echo "[1] Activating venv..."
source "$VENV_DIR/bin/activate"

# 2. Kill ports (important for delay + conflicts)
echo "[2] Freeing ports 5000 & 8000..."
fuser -k 5000/tcp 2>/dev/null
fuser -k 8000/tcp 2>/dev/null

# 3. Start backend
echo "[3] Starting backend..."
cd "$BACKEND_DIR"
nohup python app.py > backend.log 2>&1 &

# 4. Start frontend (simple HTTP server if no npm)
echo "[4] Starting frontend..."
cd "$FRONTEND_DIR"

if [ -f "package.json" ]; then
    nohup npm run dev > frontend.log 2>&1 &
else
    nohup python3 -m http.server 8000 > frontend.log 2>&1 &
fi

# 5. Check Ollama
echo "[5] Checking Ollama..."
if curl -s http://127.0.0.1:11434 > /dev/null; then
    echo "Ollama OK"
else
    echo "Starting Ollama..."
    nohup ollama serve > ollama.log 2>&1 &
    sleep 3
fi

# 6. Health check
echo "[6] Backend health..."
sleep 3
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " SYSTEM READY 🚀"
echo " Backend  : http://127.0.0.1:5000"
echo " Frontend : http://127.0.0.1:8000"
echo " Ollama   : http://127.0.0.1:11434"
echo "=============================="
