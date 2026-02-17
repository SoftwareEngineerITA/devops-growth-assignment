#!/bin/bash
# ============================================
# KUBERNETES DEPLOYMENT SCRIPT
# ============================================
# Deploy to local Kubernetes (minikube or kind)

set -e

echo "======================================"
echo "☸️  Kubernetes Deployment Pipeline"
echo "======================================"

# Step 1: Check kubectl
echo ""
echo "🔍 Step 1: Checking kubectl..."
kubectl version --client

# Step 2: Check cluster connection
echo ""
echo "🔗 Step 2: Checking cluster connection..."
kubectl cluster-info

# Step 3: Load Docker image to cluster (if using kind/minikube)
echo ""
echo "📦 Step 3: Loading image to cluster..."
if command -v kind &> /dev/null; then
    echo "Detected kind cluster, loading image..."
    kind load docker-image resilient-spring-platform:1.0.0
elif command -v minikube &> /dev/null; then
    echo "Detected minikube, loading image..."
    minikube image load resilient-spring-platform:1.0.0
else
    echo "Using existing image (assuming it's available in cluster)"
fi

# Step 4: Apply Kubernetes manifests
echo ""
echo "🚀 Step 4: Deploying to Kubernetes..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Step 5: Wait for deployment
echo ""
echo "⏳ Step 5: Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/resilient-spring-platform

# Step 6: Get deployment status
echo ""
echo "📊 Step 6: Deployment status:"
kubectl get all -l app=resilient-spring-platform

# Step 7: Get pod details
echo ""
echo "🔍 Step 7: Pod details:"
kubectl get pods -l app=resilient-spring-platform -o wide

# Step 8: Check ConfigMap
echo ""
echo "⚙️  Step 8: ConfigMap:"
kubectl get configmap app-config -o yaml

# Step 9: Get service info
echo ""
echo "🌐 Step 9: Service info:"
kubectl get svc resilient-spring-platform

# Step 10: Test application
echo ""
echo "🧪 Step 10: Testing application..."
echo "Getting NodePort..."
NODE_PORT=$(kubectl get svc resilient-spring-platform -o jsonpath='{.spec.ports[0].nodePort}')
echo "Service is available on NodePort: $NODE_PORT"

# If using minikube, get minikube IP
if command -v minikube &> /dev/null; then
    MINIKUBE_IP=$(minikube ip)
    echo ""
    echo "Testing health endpoint:"
    curl -s "http://$MINIKUBE_IP:$NODE_PORT/actuator/health" | jq '.' || curl -s "http://$MINIKUBE_IP:$NODE_PORT/actuator/health"
    
    echo ""
    echo "Testing greeting endpoint:"
    curl -s "http://$MINIKUBE_IP:$NODE_PORT/api/greet?name=Kubernetes" | jq '.' || curl -s "http://$MINIKUBE_IP:$NODE_PORT/api/greet?name=Kubernetes"
else
    echo ""
    echo "Access application at: http://localhost:$NODE_PORT"
    echo ""
    echo "Test commands:"
    echo "  curl http://localhost:$NODE_PORT/actuator/health"
    echo "  curl http://localhost:$NODE_PORT/api/greet?name=K8s"
fi

echo ""
echo "======================================"
echo "✅ Kubernetes deployment completed!"
echo "======================================"
echo ""
echo "Useful commands:"
echo "  kubectl get pods"
echo "  kubectl logs -f deployment/resilient-spring-platform"
echo "  kubectl describe pod <pod-name>"
echo "  kubectl port-forward svc/resilient-spring-platform 8080:80"
