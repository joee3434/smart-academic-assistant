#!/bin/bash

echo "=========================="
echo " CLEAN FULL RESTART"
echo "=========================="

echo "[1] Killing EVERYTHING on port 5000..."
sudo fuser -k 5000/tcp 2>/dev/null

echo "[2] Killing python backend..."
pkill -f app.py
pkill -f flask
pkill -f python3

echo "[3] Waiting..."
sleep 2

echo "[4] Activating venv..."
source venv/bin/activate

echo "[5] Starting backend fresh..."
nohup python app.py > backend.log 2>&1 &

sleep 3

echo "[6] Health check..."
curl -s http://127.0.0.1:5000/health

echo ""
echo "=========================="
echo " DONE"
echo "=========================="
