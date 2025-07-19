from fastapi import APIRouter, Depends
from pydantic import BaseModel
import py_vncorenlp
from pathlib import Path

# ⚙️ Khởi tạo py_vncorenlp (tự tải models khi chưa có)
script_path = Path(__file__).resolve()
# Directory containing the script
script_dir = script_path.parent.parent.parent
model_save_dir = str(script_dir / 'libs' / 'vncorenlp')
py_vncorenlp.download_model(save_dir=model_save_dir)
vncorenlp = py_vncorenlp.VnCoreNLP(annotators=["wseg", "pos"], save_dir=model_save_dir)

router = APIRouter(tags=["nlp"])

class Token(BaseModel):
    wordForm: str
    posTag: str

# Init model here...

@router.post("/pos-tag", response_model=list[list[Token]])
def pos_tag(sentences: list[str]):
    output: list[list[Token]] = []

    for sentence in sentences:
        last_exception = None

        for attempt in range(5):
            try:
                raw = vncorenlp.annotate_text(sentence)
                break  # Thành công → thoát vòng lặp
            except Exception as e:
                last_exception = e
                print(f"[Retry {attempt + 1}/5] Failed for sentence: '{sentence}' → {e}")
        else:
            # Nếu không break ra khỏi vòng lặp → lỗi cả 5 lần
            raise RuntimeError(f"annotate_text failed after 5 attempts for sentence: '{sentence}'") from last_exception

        sentence_tokens: list[Token] = []
        for tokens in raw.values():
            for t in tokens:
                sentence_tokens.append(Token(
                    wordForm=t["wordForm"].replace("_", " "),
                    posTag=t["posTag"]
                ))

        output.append(sentence_tokens)

    return output

