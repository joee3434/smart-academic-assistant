import fitz  # PyMuPDF

def extract_text(pdf_path):
    """Extract raw text from PDF"""
    doc = fitz.open(pdf_path)
    text = ""

    for page in doc:
        text += page.get_text()

    return text


def get_key_points(text):
    """Simple key points extraction (before AI)"""
    lines = text.split("\n")
    points = []

    for line in lines:
        line = line.strip()
        if len(line) > 40:
            points.append(line)

    return points[:20]
def chunk_text(text, size=500):
    words = text.split()
    return [
        " ".join(words[i:i+size])
        for i in range(0, len(words), size)
    ]
