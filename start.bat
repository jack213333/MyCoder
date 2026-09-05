@echo off
REM MyCoder 启动脚本
REM 优先使用项目虚拟环境 venv，若不存在则使用系统 Python
if exist venv\Scripts\python.exe (
    venv\Scripts\python.exe -m src.mycoder
) else (
    python -m src.mycoder
)
