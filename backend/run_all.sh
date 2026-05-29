#!/bin/bash

echo "================================="
echo "🚀 SMART ACADEMIC ASSISTANT START"
echo "================================="

cd "$(dirname "$0")"

# =========================
# 1. Activate venv
# =========================
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Virtual environment activated"
else
    echo "❌ venv not found"
    exit 1
fi

# =========================
# 2. Check Python deps
# =========================
echo "📦 Checking dependencies..."

pip install flask flask-cors pymupdf requests > /dev/null

# =========================
# 3. Check Ollama
# =========================
echo "🧠 Checking Ollama..."

curl -s http://127.0.0.1:11434 > /dev/null

if [ $? -ne 0 ]; then
    echo "⚠️ Ollama is NOT running!"
    echo "👉 Run: ollama serve"
    exit 1
else
    echo "✅ Ollama is running"
fi

# =========================
# 4. Start Backend
# =========================
echo "🔥 Starting backend..."

fuser -k 5000/tcp > /dev/null 2>&1

python app.py &
BACK_PID=$!

sleep 3

# =========================
# 5. Start Frontend
# =========================
echo "🌐 Starting frontend..."

fuser -k 8000/tcp > /dev/null 2>&1

cd ..
cd frontend 2>/dev/null || cd backend

python3 -m http.server 8000 &
FRONT_PID=$!

sleep 2

# =========================
# 6. Final Status
# =========================
echo "================================="
echo "✅ SYSTEM RUNNING"
echo "---------------------------------"
echo "Backend  : http://127.0.0.1:5000"
echo "Frontend : http://127.0.0.1:8000"
echo "Ollama   : http://127.0.0.1:11434"
echo "================================="

echo "Press CTRL+C to stop all"

# =========================
# 7. Cleanup on exit
# =========================
trap "kill $BACK_PID $FRONT_PID; echo 'Stopped.'" EXIT

wait
