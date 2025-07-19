from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime, timezone
from .nlp import router as nlp_router
from .embed import router as embed_router

api = APIRouter(prefix="/api/plugins", tags=["/api/plugins"])
api.include_router(nlp_router)
api.include_router(embed_router)

class HelloResponse(BaseModel):
    message: str
    time: datetime

@api.get("/hello", response_model=HelloResponse)
def hello():
    now = datetime.now(timezone.utc).isoformat()
    return {"message": "Hello!", "time": now}