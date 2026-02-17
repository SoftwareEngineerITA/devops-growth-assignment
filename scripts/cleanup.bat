@echo off
REM ============================================
REM CLEANUP - Windows WSL2 Wrapper
REM ============================================

echo ======================================
echo Cleanup Resources (WSL2)
echo ======================================
echo.

cd /d "%~dp0.."

echo Cleaning up...
wsl -d Ubuntu -- bash -c "cd '/mnt/c/Users/milos.merdovic/OneDrive/Desktop/Presentation for upskilling/resilient-spring-platform' && bash scripts/cleanup.sh"

echo.
echo ======================================
echo Cleanup completed!
echo ======================================
pause
