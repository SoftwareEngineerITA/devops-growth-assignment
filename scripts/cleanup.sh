#!/bin/bash
# ============================================
# CLEANUP SCRIPT
# ============================================

echo "🧹 Cleaning up resources..."

# Kubernetes cleanup
echo ""
echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/ 2>/dev/null || true

# Docker cleanup
echo ""
echo "Stopping Docker containers..."
docker stop spring-app 2>/dev/null || true
docker rm spring-app 2>/dev/null || true

echo ""
echo "✅ Cleanup completed!"
