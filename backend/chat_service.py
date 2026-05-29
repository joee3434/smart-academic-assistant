import requests

class ChatService:

    def __init__(self):
        self.url = "http://localhost:11434/api/generate"
        self.model = "llama3.2:1b"

    def generate(self, message):

        response = requests.post(
            self.url,
            json={
                "model": self.model,
                "prompt": message,
                "stream": False
            }
        )

        data = response.json()

        return data.get("response", "")
