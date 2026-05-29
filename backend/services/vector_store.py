import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

class VectorStore:
    def __init__(self):
        self.model = SentenceTransformer("all-MiniLM-L6-v2")

        self.index = faiss.IndexFlatL2(384)
        self.chunks = []

    def add_text(self, chunks):
        vectors = self.model.encode(chunks)

        self.index.add(np.array(vectors))
        self.chunks.extend(chunks)

    def search(self, query, k=5):
        q_vec = self.model.encode([query])

        distances, indices = self.index.search(np.array(q_vec), k)

        results = []
        for i in indices[0]:
            if i < len(self.chunks):
                results.append(self.chunks[i])

        return results
