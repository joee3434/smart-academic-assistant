from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from pypdf import PdfReader

app = Flask(__name__)
CORS(app)

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.2:1b"

# -----------------------------
# Memory (simple in-memory DB)
# -----------------------------
documents = {}

# -----------------------------
# Helpers
# -----------------------------
def call_llm(prompt):
    try:
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": MODEL,
                "prompt": prompt,
                "stream": False
            },
            timeout=180
        )
        return response.json().get("response", "")
    except Exception as e:
        return f"LLM Error: {str(e)}"


def extract_text_from_pdf(file):
    reader = PdfReader(file)
    text = ""
    for page in reader.pages:
        text += page.extract_text() or ""
    return text


# -----------------------------
# Health Check
# -----------------------------
@app.route("/health")
def health():
    return {"status": "ok", "service": "smart-academic-assistant"}


# -----------------------------
# Upload PDF
# -----------------------------
@app.route("/upload", methods=["POST"])
def upload_pdf():
    if "file" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["file"]
    text = extract_text_from_pdf(file)

    doc_id = str(len(documents) + 1)
    documents[doc_id] = text

    return jsonify({
        "message": "File uploaded successfully",
        "doc_id": doc_id,
        "length": len(text)
    })


# -----------------------------
# Summarize lecture
# -----------------------------
@app.route("/summarize", methods=["POST"])
def summarize():
    data = request.json
    doc_id = data.get("doc_id")

    text = documents.get(doc_id, "")
    if not text:
        return jsonify({"error": "Document not found"}), 404

    prompt = f"""
Summarize this lecture into clear bullet points:

{text}
"""

    summary = call_llm(prompt)

    return jsonify({"summary": summary})


# -----------------------------
# Ask questions (RAG basic)
# -----------------------------
@app.route("/ask", methods=["POST"])
def ask():
    data = request.json
    question = data.get("question")
    doc_id = data.get("doc_id")

    text = documents.get(doc_id, "")
    if not text:
        return jsonify({"error": "Document not found"}), 404

    prompt = f"""
You are a university academic assistant.
Answer ONLY from the lecture content below.

Lecture:
{text}

Question:
{question}
"""

    answer = call_llm(prompt)

    return jsonify({"answer": answer})


# -----------------------------
# Generate Quiz
# -----------------------------
@app.route("/quiz", methods=["POST"])
def quiz():
    data = request.json
    doc_id = data.get("doc_id")

    text = documents.get(doc_id, "")
    if not text:
        return jsonify({"error": "Document not found"}), 404

    prompt = f"""
Create 5 multiple-choice questions (MCQ) from this lecture.
Include answers at the end.

Lecture:
{text}
"""

    quiz = call_llm(prompt)

    return jsonify({"quiz": quiz})


# -----------------------------
# Run server
# -----------------------------
if __name__ == "__main__":
    app.run(debug=True, port=5000)
