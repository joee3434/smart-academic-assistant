#!/bin/bash

echo "=============================="
echo "  HARD FIX BACKEND + OLLAMA"
echo "=============================="

# 1. Kill everything
echo "[1] Killing processes..."
sudo pkill -9 -f app.py
sudo pkill -9 -f flask
sudo fuser -k 5000/tcp

# 2. Wait
sleep 2

# 3. Activate env
echo "[2] Activating venv..."
source venv/bin/activate

# 4. Check Ollama health
echo "[3] Checking Ollama..."
curl -s http://127.0.0.1:11434/api/tags || {
  echo "❌ Ollama not running"
  exit 1
}

# 5. Test fast model (IMPORTANT)
echo "[4] Testing model speed..."
curl -s http://127.0.0.1:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "hi",
  "stream": false
}'

echo ""
echo "[5] Starting backend..."
python app.py &
BACKEND_PID=$!

sleep 5

echo "[6] Health check..."
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " FIX DONE"
echo "=============================="
echo "Backend PID: $BACKEND_PID"
echo "If /ask still fails -> code bug in app.py"
echo "=============================="
