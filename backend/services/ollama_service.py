import requests

class OllamaService:
    def __init__(self):
        self.base_url = "http://localhost:11434"
        self.model = "llama3.2:1b"

    def generate(self, message: str) -> str:
        try:
            url = f"{self.base_url}/api/generate"

            payload = {
                "model": self.model,
                "prompt": self.build_prompt(message),
                "stream": False
            }

            response = requests.post(url, json=payload, timeout=120)
            response.raise_for_status()

            data = response.json()
            return data.get("response", "No response from model")

        except requests.exceptions.Timeout:
            return "Error: Ollama request timed out. Try again."
        
        except requests.exceptions.ConnectionError:
            return "Error: Cannot connect to Ollama. Is it running on port 11434?"
        
        except Exception as e:
            return f"Error: {str(e)}"

    def build_prompt(self, message: str) -> str:
        return f"""
You are a helpful academic assistant.
Answer clearly, concisely, and correctly.

User question:
{message}

Assistant:
"""
