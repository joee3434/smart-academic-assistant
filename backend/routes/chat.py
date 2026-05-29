from flask import Blueprint, request, jsonify
from services.chat_service import ChatService

chat_bp = Blueprint("chat", __name__)
chat_service = ChatService()

@chat_bp.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    message = data.get("message", "")

    reply = chat_service.chat(message)

    return jsonify({
        "response": reply
    })
