#!/bin/bash

echo "============================"
echo "  SMART ASSISTANT FIXER"
echo "============================"

echo "[1] Killing old processes..."

sudo fuser -k 5000/tcp 2>/dev/null
sudo fuser -k 8000/tcp 2>/dev/null
pkill -9 -f "python app.py" 2>/dev/null
pkill -9 -f flask 2>/dev/null

echo "[2] Activating environment..."
cd ~/smart-academic-assistant/backend || exit 1
source venv/bin/activate

echo "[3] Checking Ollama..."
curl -s http://127.0.0.1:11434/api/tags > /dev/null
if [ $? -ne 0 ]; then
    echo "Starting Ollama..."
    nohup ollama serve > ollama.log 2>&1 &
    sleep 3
fi

echo "[4] Starting Backend..."
nohup python app.py > backend.log 2>&1 &
sleep 3

echo "[5] Checking Backend..."
curl -s http://127.0.0.1:5000/health
echo ""

echo "[6] Starting Frontend..."
cd ../frontend || echo "No frontend folder"
nohup python -m http.server 8000 > frontend.log 2>&1 &

echo "============================"
echo " SYSTEM READY"
echo " Backend : http://127.0.0.1:5000"
echo " Frontend: http://127.0.0.1:8000"
echo " Ollama  : http://127.0.0.1:11434"
echo "============================"
