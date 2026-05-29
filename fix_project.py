import os
import shutil

BASE = os.path.dirname(os.path.abspath(__file__))

print("🔧 Cleaning Smart Academic Assistant Project...")

# =========================
# 1. Standardize backend API response
# =========================

backend_app = os.path.join(BASE, "backend/app.py")

with open(backend_app, "r") as f:
    code = f.read()

# Fix inconsistent response key (answer → response)
code = code.replace('"answer"', '"response"')

with open(backend_app, "w") as f:
    f.write(code)

print("✅ Fixed backend response keys")

# =========================
# 2. Fix frontend (index.html in backend)
# =========================

backend_front = os.path.join(BASE, "backend/index.html")

if os.path.exists(backend_front):
    with open(backend_front, "r") as f:
        html = f.read()

    # Fix wrong field usage in JS
    html = html.replace("data.answer", "data.response")
    html = html.replace("doc_id = data.file_path", "doc_id = data.doc_id")

    with open(backend_front, "w") as f:
        f.write(html)

    print("✅ Fixed backend frontend HTML")

# =========================
# 3. Remove duplicate confusion (optional cleanup hint)
# =========================

print("\n⚠️ Manual check needed:")
print("- backend/chat_service.py (NOT USED in current app.py)")
print("- backend/services/chat_service.py (actual logic)")
print("\n👉 Recommendation: delete backend/chat_service.py if unused")

# =========================
# 4. Create unified API contract note
# =========================

contract = """
API CONTRACT:

POST /upload
→ returns: { doc_id }

POST /ask
body: { doc_id, question }
→ returns: { response }

POST /summarize
→ returns: { summary }

POST /quiz
→ returns: { quiz }
"""

with open(os.path.join(BASE, "API_CONTRACT.txt"), "w") as f:
    f.write(contract)

print("✅ Created API contract file")

# =========================
# DONE
# =========================

print("\n🚀 PROJECT CLEANED SUCCESSFULLY")
print("Now run:")
print("  python backend/app.py")
print("  python3 -m http.server 8000 (if needed)")
