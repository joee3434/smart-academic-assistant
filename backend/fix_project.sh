#!/bin/bash

echo "=============================="
echo " FULL PROJECT FIX START"
echo "=============================="

cd "$(dirname "$0")"

echo "[1] Stopping old backend..."
sudo pkill -f "python app.py"
sudo fuser -k 5000/tcp 2>/dev/null

echo "[2] Fixing broken app.py..."

cat > app.py << 'EOF'
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import fitz
import requests

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

docs_store = {}

# -----------------------------
# PDF TEXT EXTRACTION
# -----------------------------
def extract_text(pdf_path):
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text()
    return text

# -----------------------------
# LLM CALL (OLLAMA)
# -----------------------------
def call_llm(prompt):
    try:
        res = requests.post(
            "http://127.0.0.1:11434/api/generate",
            json={
                "model": "llama3.2:1b",
                "prompt": prompt,
                "stream": False
            },
            timeout=300
        )
        return res.json().get("response", "")
    except Exception as e:
        return f"LLM error: {str(e)}"

# -----------------------------
# UPLOAD PDF
# -----------------------------
@app.route("/upload", methods=["POST"])
def upload_file():
    if "file" not in request.files:
        return jsonify({"error": "no file provided"}), 400

    file = request.files["file"]
    path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(path)

    text = extract_text(path)

    doc_id = str(len(docs_store) + 1)
    docs_store[doc_id] = text

    return jsonify({
        "message": "uploaded successfully",
        "doc_id": doc_id
    })

# -----------------------------
# ASK (FIXED - SINGLE ROUTE ONLY)
# -----------------------------
@app.route("/ask", methods=["POST"])
def ask():
    data = request.json or {}
    question = data.get("question")
    doc_id = data.get("doc_id")

    if not question:
        return jsonify({"error": "missing question"}), 400

    if doc_id not in docs_store:
        return jsonify({
            "error": "document not found",
            "available_docs": list(docs_store.keys())
        }), 404

    context = docs_store[doc_id][:3000]

    prompt = f"""
You are an expert academic assistant.

Use the context below to answer the question.

Context:
{context}

Question:
{question}

Answer clearly and concisely.
"""

    response = call_llm(prompt)

    return jsonify({
        "question": question,
        "response": response
    })

# -----------------------------
# HEALTH CHECK
# -----------------------------
@app.route("/health")
def health():
    return jsonify({
        "status": "ok",
        "docs_loaded": len(docs_store)
    })

# -----------------------------
# MAIN
# -----------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
EOF

echo "[3] Reinstall safety deps..."
pip install flask flask-cors pymupdf requests --quiet

echo "[4] Starting backend..."
nohup python app.py > backend.log 2>&1 &

sleep 3

echo "[5] Health check..."
curl -s http://127.0.0.1:5000/health

echo ""
echo "=============================="
echo " FIX COMPLETE"
echo "=============================="
