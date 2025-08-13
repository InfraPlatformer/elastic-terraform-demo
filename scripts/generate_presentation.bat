@echo off
echo Creating PowerPoint Presentation...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Install required packages
echo Installing required packages...
pip install -r requirements.txt

REM Run the presentation generator
echo.
echo Generating presentation...
python create_presentation.py

echo.
echo Done!
pause


