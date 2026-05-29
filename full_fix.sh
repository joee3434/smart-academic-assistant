#!/bin/bash

BASE=~/smart-academic-assistant
BACKEND=$BASE/backend
APP=$BACKEND/app.py

echo "=============================="
echo " FULL SYSTEM AUTO REPAIR"
echo "=============================="

# 1) Backup
echo "[1] Backup app.py..."
cp $APP $APP.backup.$(date +%s)

# 2) Create persistence file
echo "[2] Creating docs.json..."
echo "{}" > $BACKEND/docs.json

# 3) Inject persistence layer into app.py (safe patch)
echo "[3] Patching app.py..."

python3 - << 'EOF'
import re

path = "~/smart-academic-assistant/backend/app.py"
path = path.replace("~", "/home/youssef-amr")

with open(path, "r") as f:
    code = f.read()

# If already patched, skip
if "load_docs" in code:
    print("Already patched")
    exit()

persistence_code = '''
import json
import os

DOCS_FILE = "docs.json"

def load_docs():
    if os.path.exists(DOCS_FILE):
        try:
            with open(DOCS_FILE, "r") as f:
                return json.load(f)
        except:
            return {}
    return {}

def save_docs(docs):
    with open(DOCS_FILE, "w") as f:
        json.dump(docs, f)

docs = load_docs()
'''

# inject after imports
parts = code.split("\n")

insert_index = 0
for i, line in enumerate(parts):
    if "Flask" in line or "flask" in line:
        insert_index = i + 1

parts.insert(insert_index, persistence_code)

new_code = "\n".join(parts)

# fix common bug patterns
new_code = re.sub(r"docs\s*=\s*\{\}", "docs = load_docs()", new_code)

with open(path, "w") as f:
    f.write(new_code)

print("Patch applied successfully")
EOF

# 4) Kill old processes
echo "[4] Restarting backend/frontend..."
pkill -f "python app.py" || true
pkill -f "http.server 8000" || true

# 5) Start backend
cd $BACKEND
source venv/bin/activate
nohup python app.py > backend.log 2>&1 &

sleep 2

# 6) Start frontend
cd $BASE/frontend
nohup python3 -m http.server 8000 > frontend.log 2>&1 &

sleep 2

# 7) Health check
echo "[5] Health check..."
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " SYSTEM FIXED 🚀"
echo "=============================="
echo "Backend : http://127.0.0.1:5000"
echo "Frontend: http://127.0.0.1:8000"
echo "=============================="
