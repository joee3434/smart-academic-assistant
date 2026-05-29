from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import fitz
import requests

app = Flask(__name__)

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

CORS(app)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

docs_store = {}

# =========================
# PDF TEXT EXTRACTION
# =========================
def extract_text(pdf_path):
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text()
    return text

# =========================
# LLM CALL (OLLAMA)
# =========================
def call_llm(prompt):
    try:
        res = requests.post(
            "http://127.0.0.1:11434/api/generate",
            json={
                "model": "llama3.2:1b",
                "prompt": prompt[:2000],
                "stream": False
            },
            timeout=600
        )

        if res.status_code != 200:
            return f"LLM HTTP ERROR: {res.text}"

        return res.json().get("response", "")

    except requests.exceptions.Timeout:
        return "LLM TIMEOUT"
    except Exception as e:
        return f"LLM ERROR: {str(e)}"

# =========================
# UPLOAD PDF
# =========================
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

# =========================
# ASK
# =========================
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

    context = docs_store[doc_id][:1200]

    prompt = f"""
You are an expert academic assistant.

Use ONLY the context below.

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

# =========================
# HEALTH
# =========================
@app.route("/health")
def health():
    return jsonify({
        "status": "ok",
        "docs_loaded": len(docs_store)
    })

# =========================
# RUN
# =========================
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False
    )
