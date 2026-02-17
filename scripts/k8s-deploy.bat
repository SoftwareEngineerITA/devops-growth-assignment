@echo off
REM ============================================
REM KUBERNETES DEPLOYMENT - Windows WSL2 Wrapper
REM ============================================

echo ======================================
echo Kubernetes Deployment (WSL2)
echo ======================================
echo.

cd /d "%~dp0.."

echo Deploying to Kubernetes...
wsl -d Ubuntu -- bash -c "cd '/mnt/c/Users/milos.merdovic/OneDrive/Desktop/Presentation for upskilling/resilient-spring-platform' && bash scripts/k8s-deploy.sh"

echo.
echo ======================================
echo Deployment completed!
echo ======================================
pause
