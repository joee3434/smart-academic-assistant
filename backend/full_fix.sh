#!/bin/bash

echo "=============================="
echo " FULL SYSTEM FIX START"
echo "=============================="

# 1) Kill everything
echo "[1] Killing old processes..."
sudo fuser -k 5000/tcp 2>/dev/null
sudo fuser -k 8000/tcp 2>/dev/null
pkill -9 -f "app.py" 2>/dev/null
pkill -9 -f flask 2>/dev/null
pkill -9 -f python 2>/dev/null

# 2) Go to backend
echo "[2] Going to backend..."
cd ~/smart-academic-assistant/backend || exit 1

# 3) Activate venv
echo "[3] Activating venv..."
source venv/bin/activate

# 4) Force Ollama lightweight model
echo "[4] Setting Ollama model (fast mode)..."

export OLLAMA_MODEL="llama3.2:1b"

# 5) Ensure Ollama is running
echo "[5] Checking Ollama..."
curl -s http://127.0.0.1:11434/api/tags > /dev/null
if [ $? -ne 0 ]; then
    echo "Starting Ollama..."
    nohup ollama serve > ollama.log 2>&1 &
    sleep 5
fi

# 6) Clean cache folders (important for RAG bugs)
echo "[6] Cleaning vector cache..."
rm -rf vectors/*
rm -rf docs_store/*

# 7) Start backend clean
echo "[7] Starting backend..."
nohup python app.py > backend.log 2>&1 &

sleep 5

# 8) Health check
echo "[8] Backend health check..."
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " SYSTEM READY"
echo " Backend : http://127.0.0.1:5000"
echo " Frontend: http://127.0.0.1:8000"
echo " Ollama  : http://127.0.0.1:11434"
echo " Model   : llama3.2:1b (FAST)"
echo "=============================="
