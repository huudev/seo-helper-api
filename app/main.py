from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime, timezone
from .routers.nlp import router as nlp_router
from .routers.embed import router as embed_router

# 🌐 app FastAPI
app = FastAPI(
    title="Seo helper REST API",
    version="1.0",
)

# Mở CORS cho mọi domain
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(nlp_router)
app.include_router(embed_router)

class HelloResponse(BaseModel):
    message: str
    time: datetime

@app.get("/api/hello", response_model=HelloResponse)
def hello():
    now = datetime.now(timezone.utc).isoformat()
    return {"message": "Hello!", "time": now}
