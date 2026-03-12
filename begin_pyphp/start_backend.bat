@echo off
cd backend
pip install -r requirements.txt
cd ..
echo Starting Python Backend (uvicorn)...
python -m uvicorn backend.app:app --host 127.0.0.1 --port 8000 --reload
