from services.ollama_service import OllamaService

class ChatService:
    def __init__(self):
        self.llm = OllamaService()

    def chat(self, message):
        return self.llm.generate(message)
