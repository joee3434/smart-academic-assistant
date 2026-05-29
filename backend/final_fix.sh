#!/bin/bash

echo "=============================="
echo " FULL FINAL FIX"
echo "=============================="

# 1. Kill backend
echo "[1] Stopping backend..."
fuser -k 5000/tcp 2>/dev/null
pkill -f "python app.py" 2>/dev/null

# 2. Activate venv
echo "[2] Activating venv..."
source venv/bin/activate

# 3. Install dependencies safe
echo "[3] Installing deps..."
pip install flask flask-cors requests pymupdf --quiet

# 4. Ensure uploads folder exists
echo "[4] Creating folders..."
mkdir -p uploads

# 5. Start backend clean
echo "[5] Starting backend..."
nohup python app.py > backend.log 2>&1 &

sleep 3

# 6. Health check
echo "[6] Health check..."
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " DONE"
echo " Backend: http://127.0.0.1:5000"
echo "=============================="
