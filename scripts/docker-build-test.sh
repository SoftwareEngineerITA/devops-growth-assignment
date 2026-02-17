#!/bin/bash
# ============================================
# DOCKER BUILD & TEST SCRIPT
# ============================================
# Koristiti u WSL2 Ubuntu

set -e  # Exit on error

echo "======================================"
echo "🐳 Docker Build & Test Pipeline"
echo "======================================"

# Step 1: Build Docker image
echo ""
echo "📦 Step 1: Building Docker image..."
docker build -t resilient-spring-platform:1.0.0 .

# Step 2: Check image size
echo ""
echo "📊 Step 2: Image info:"
docker images resilient-spring-platform:1.0.0

# Step 3: Stop existing container (if running)
echo ""
echo "🛑 Step 3: Cleaning up old containers..."
docker stop spring-app 2>/dev/null || true
docker rm spring-app 2>/dev/null || true

# Step 4: Run container
echo ""
echo "🚀 Step 4: Starting container..."
docker run -d \
  --name spring-app \
  -p 8080:8080 \
  -e APP_GREETING_MESSAGE="Hello from Docker" \
  -e APP_ENVIRONMENT="docker-wsl2" \
  resilient-spring-platform:1.0.0

# Step 5: Wait for startup
echo ""
echo "⏳ Step 5: Waiting for application startup (15 seconds)..."
sleep 15

# Step 6: Test health endpoint
echo ""
echo "🏥 Step 6: Testing health endpoint..."
curl -s http://localhost:8080/actuator/health | jq '.' || curl -s http://localhost:8080/actuator/health

# Step 7: Test greeting endpoint
echo ""
echo "👋 Step 7: Testing greeting endpoint..."
curl -s "http://localhost:8080/api/greet?name=WSL2" | jq '.' || curl -s "http://localhost:8080/api/greet?name=WSL2"

# Step 8: Test status endpoint
echo ""
echo "✅ Step 8: Testing status endpoint..."
curl -s http://localhost:8080/api/status

# Step 9: Check container health
echo ""
echo "💊 Step 9: Container health status:"
docker inspect --format='{{.State.Health.Status}}' spring-app 2>/dev/null || echo "Health check not ready yet"

# Step 10: Show logs
echo ""
echo "📋 Step 10: Container logs (last 20 lines):"
docker logs --tail 20 spring-app

echo ""
echo "======================================"
echo "✅ Docker test completed successfully!"
echo "======================================"
echo ""
echo "Container is running. To stop:"
echo "  docker stop spring-app && docker rm spring-app"
echo ""
echo "To view logs:"
echo "  docker logs -f spring-app"
