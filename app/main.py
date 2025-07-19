from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers.api import api as api_router
# 🌐 app FastAPI
app = FastAPI(
    title="Seo helper REST API",
    version="1.0",
)

# Mở CORS cho mọi domain
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)