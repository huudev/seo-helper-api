if exist ".\.venv\Scripts\activate.bat" (
    .\.venv\Scripts\activate.bat && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
) else (
    uvicorn app.main:app --host 0.0.0.0 --port 8000
)