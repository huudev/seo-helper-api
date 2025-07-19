from fastapi import APIRouter
from sentence_transformers import SentenceTransformer

router = APIRouter(tags=["embed"])

# Initialize model once
model = SentenceTransformer("AITeamVN/Vietnamese_Embedding_v2")
model.max_seq_length = 2048

@router.post("/embed", response_model=list[list[float]])
def embed_texts(texts: list[str]):
    embeddings = model.encode(texts, show_progress_bar=False)
    return embeddings.tolist()
