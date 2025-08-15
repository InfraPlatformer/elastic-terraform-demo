@echo off
echo ========================================
echo    Large Files Cleanup Script
echo ========================================
echo.
echo This script will move large directories to D: drive
echo to free up space on your C: drive.
echo.
echo Options:
echo 1. Dry Run (see what would be moved)
echo 2. Move files (create symbolic links)
echo 3. Move files (no symbolic links)
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo Running in DRY RUN mode...
    powershell -ExecutionPolicy Bypass -File "%~dp0move-large-files.ps1" -DryRun
) else if "%choice%"=="2" (
    echo.
    echo Moving files and creating symbolic links...
    powershell -ExecutionPolicy Bypass -File "%~dp0move-large-files.ps1" -Force
) else if "%choice%"=="3" (
    echo.
    echo Moving files (no symbolic links)...
    powershell -ExecutionPolicy Bypass -File "%~dp0move-large-files.ps1"
) else if "%choice%"=="4" (
    echo Exiting...
    exit /b 0
) else (
    echo Invalid choice. Please run the script again.
    pause
    exit /b 1
)

echo.
echo Script completed. Press any key to exit...
pause >nul
