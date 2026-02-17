@echo off
REM ============================================
REM FAILURE SCENARIOS TEST - Windows WSL2 Wrapper
REM ============================================

echo ======================================
echo Failure Scenarios Testing (WSL2)
echo ======================================
echo.

cd /d "%~dp0.."

echo Running failure scenarios...
wsl -d Ubuntu -- bash -c "cd '/mnt/c/Users/milos.merdovic/OneDrive/Desktop/Presentation for upskilling/resilient-spring-platform' && bash scripts/test-failure-scenarios.sh"

echo.
echo ======================================
echo Testing completed!
echo ======================================
pause
