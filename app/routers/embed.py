from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
from sentence_transformers import SentenceTransformer

router = APIRouter(prefix="/api", tags=["embed"])

# Initialize model once
model = SentenceTransformer("AITeamVN/Vietnamese_Embedding_v2")
model.max_seq_length = 2048

@router.post("/embed", response_model=List[List[float]])
def embed_texts(texts: List[str]):
    embeddings = model.encode(texts, show_progress_bar=False)
    return embeddings.tolist()
