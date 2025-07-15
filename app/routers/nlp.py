from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import List
import py_vncorenlp
from pathlib import Path

# ⚙️ Khởi tạo py_vncorenlp (tự tải models khi chưa có)
script_path = Path(__file__).resolve()
# Directory containing the script
script_dir = script_path.parent.parent.parent
model_save_dir = str(script_dir / 'libs' / 'vncorenlp')
py_vncorenlp.download_model(save_dir=model_save_dir)
vncorenlp = py_vncorenlp.VnCoreNLP(annotators=["wseg", "pos"], save_dir=model_save_dir)

router = APIRouter(
    prefix="/api",
    tags=["nlp"],
)

class Token(BaseModel):
    wordForm: str
    posTag: str

# Init model here...

@router.post("/parse", response_model=List[List[Token]])
def parse(sentences: List[str]):
    output: List[List[Token]] = []

    for sentence in sentences:
        raw = vncorenlp.annotate_text(sentence)
        # Có thể kết hợp nhiều sentence nếu CoreNLP trả nhiều key
        sentence_tokens: List[Token] = []

        for tokens in raw.values():
            for t in tokens:
                sentence_tokens.append(Token(
                    wordForm=t["wordForm"].replace("_", " "),
                    posTag=t["posTag"]
                ))

        output.append(sentence_tokens)

    return output
