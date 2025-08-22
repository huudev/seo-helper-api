from fastapi import APIRouter
from g4f.client import Client
from pydantic import BaseModel

router = APIRouter(tags=["chat_bot"])

client = Client()

class ChatBotResponse(BaseModel):
    message: str

class ChatBotRequest(BaseModel):
    message: str

@router.post("/chat_bot", response_model=ChatBotResponse)
def chat_bot(request: ChatBotRequest):
    response = client.chat.completions.create(
            provider="Chatai",
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": request.message}],
            web_search=False
        )
    return ChatBotResponse(message=response.choices[0].message.content)
