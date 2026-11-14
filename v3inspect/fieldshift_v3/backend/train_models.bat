@echo off
cd /d %~dp0
call .venv\Scripts\activate
python train_models.py
pause
