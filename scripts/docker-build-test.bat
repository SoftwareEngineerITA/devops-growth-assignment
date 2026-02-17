@echo off
REM ============================================
REM DOCKER BUILD & TEST - Windows WSL2 Wrapper
REM ============================================

echo ======================================
echo Docker Build ^& Test Pipeline (WSL2)
echo ======================================
echo.

cd /d "%~dp0.."

echo Starting Docker build in WSL2...
wsl -d Ubuntu -- bash -c "cd '/mnt/c/Users/milos.merdovic/OneDrive/Desktop/Presentation for upskilling/resilient-spring-platform' && bash scripts/docker-build-test.sh"

echo.
echo ======================================
echo Build completed!
echo ======================================
pause
