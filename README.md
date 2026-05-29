# Smart Academic Assistant

AI-powered academic assistant for document upload, summarization, and intelligent question answering.

---

## Features

* Upload academic documents (PDF / DOCX / PPTX)
* AI-powered document summarization
* Context-aware Q&A system
* Flask backend API
* Modern frontend interface
* Ollama local LLM integration
* One-command full startup system

---

## Tech Stack

### Backend

* Python
* Flask
* Ollama
* Vector Search / Context Retrieval

### Frontend

* HTML
* TailwindCSS
* JavaScript

### AI Layer

* Ollama Local Models

---

## Project Structure

```bash
smart-academic-assistant/
│
├── backend/
│   ├── app.py
│   ├── routes/
│   ├── services/
│   ├── uploads/
│   └── db/
│
├── frontend/
│   ├── index.html
│   └── app.py
│
├── chat.sh
├── fix_project.py
└── README.md
```

---

## Installation

Clone repository:

```bash
git clone https://github.com/joee3434/smart-academic-assistant.git
cd smart-academic-assistant
```

Create virtual environment:

```bash
cd backend

python3 -m venv venv

source venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Install Ollama.

Start Ollama model.

---

## Run Project

The project supports one-command startup.

Run:

```bash
chat
```

This automatically launches:

* Backend Server
* Frontend Server
* Ollama
* Health Check
* Port Cleanup

---

## Access

Backend:

```text
http://127.0.0.1:5000
```

Frontend:

```text
http://127.0.0.1:8000
```

Ollama:

```text
http://127.0.0.1:11434
```

---

## Example Workflow

1. Upload document.
2. Receive document ID.
3. Ask questions about uploaded content.
4. Generate summaries and contextual answers.

Example:

```text
You: What is Python?

AI: Python is a general-purpose programming language known for simplicity and versatility.
```

---

## Author

Youssef Amr

Smart Academic Assistant — Local AI Academic Workspace.
