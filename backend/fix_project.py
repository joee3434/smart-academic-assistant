import os

BACKEND_FILE = "app.py"
FRONTEND_FILE = "index.html"


# =========================
# FIX BACKEND
# =========================
backend_fixed = """
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


def extract_text(pdf_path):
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text()
    return text


def call_llm(prompt):
    try:
        res = requests.post(
            "http://127.0.0.1:11434/api/generate",
            json={
                "model": "llama3.2:1b",
                "prompt": prompt,
                "stream": False
            },
            timeout=120
        )
        return res.json().get("response", "")
    except Exception as e:
        return f"LLM error: {str(e)}"


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


@app.route("/ask", methods=["POST"])
def ask():
    data = request.json
    question = data.get("question")
    doc_id = data.get("doc_id")

    text = docs_store.get(doc_id)

    if not text:
        return jsonify({
            "error": "document not found",
            "available_docs": list(docs_store.keys())
        }), 404

    context = text[:3000]

    prompt = f\"\"\"
You are an expert academic assistant.

Context:
{context}

Question:
{question}

Answer:
\"\"\"

    response = call_llm(prompt)

    return jsonify({
        "question": question,
        "response": response
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "ok",
        "docs_loaded": len(docs_store)
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
"""


# =========================
# FIX FRONTEND
# =========================
frontend_fixed = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Smart Academic Assistant</title>

<style>
* { margin:0; padding:0; box-sizing:border-box; font-family:Arial; }

body {
  height:100vh;
  display:flex;
  background:#0b1220;
  color:white;
}

.sidebar {
  width:280px;
  background:#111827;
  padding:15px;
  display:flex;
  flex-direction:column;
  gap:10px;
}

.upload {
  background:#2563eb;
  padding:12px;
  border-radius:10px;
  cursor:pointer;
  text-align:center;
}

input[type=file] { display:none; }

.chat {
  flex:1;
  display:flex;
  flex-direction:column;
}

.messages {
  flex:1;
  padding:20px;
  overflow-y:auto;
}

.msg {
  max-width:70%;
  padding:10px;
  margin:5px;
  border-radius:10px;
}

.user { background:#2563eb; align-self:flex-end; }
.bot { background:#1f2937; align-self:flex-start; }

.input-box {
  display:flex;
  padding:10px;
}

.input-box input {
  flex:1;
  padding:10px;
}

.input-box button {
  padding:10px;
}
</style>
</head>

<body>

<div class="sidebar">
  <h3>Smart Assistant</h3>

  <label class="upload">
    Upload PDF
    <input type="file" id="fileInput" onchange="uploadPDF()">
  </label>

  <div id="status">No file</div>
</div>

<div class="chat">
  <div class="messages" id="messages"></div>

  <div class="input-box">
    <input id="question" placeholder="Ask something...">
    <button onclick="sendMessage()">Send</button>
  </div>
</div>

<script>

let docId = null;

/* UPLOAD */
async function uploadPDF() {
  const file = document.getElementById("fileInput").files[0];
  if (!file) return;

  let formData = new FormData();
  formData.append("file", file);

  document.getElementById("status").innerText = "Uploading...";

  const res = await fetch("http://127.0.0.1:5000/upload", {
    method: "POST",
    body: formData
  });

  const data = await res.json();

  docId = data.doc_id;

  document.getElementById("status").innerText = "Loaded: " + file.name;

  addMsg("Uploaded ✔", "bot");
}

/* CHAT */
async function sendMessage() {
  const input = document.getElementById("question");
  const text = input.value.trim();

  if (!text) return;

  addMsg(text, "user");
  input.value = "";

  addMsg("Thinking...", "bot");

  const res = await fetch("http://127.0.0.1:5000/ask", {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({
      doc_id: docId,
      question: text
    })
  });

  const data = await res.json();

  removeLastBot();
  addMsg(data.response || data.error, "bot");
}

/* UI */
function addMsg(text, type) {
  const div = document.createElement("div");
  div.className = "msg " + type;
  div.innerText = text;
  document.getElementById("messages").appendChild(div);
}

function removeLastBot() {
  const bots = document.querySelectorAll(".msg.bot");
  if (bots.length) bots[bots.length - 1].remove();
}
</script>

</body>
</html>
"""


# =========================
# WRITE FILES
# =========================
def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


if __name__ == "__main__":
    write_file(BACKEND_FILE, backend_fixed)
    write_file(FRONTEND_FILE, frontend_fixed)

    print("✅ Project fixed successfully!")
    print("👉 Restart backend:")
    print("   python app.py")
