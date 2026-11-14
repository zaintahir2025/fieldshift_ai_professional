@echo off
cd /d %~dp0\backend
if not exist .venv py -m venv .venv
call .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --reload --host 127.0.0.1 --port 8000
pause
