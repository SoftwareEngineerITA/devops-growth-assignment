#!/bin/bash
# ============================================
# FAILURE SCENARIOS DEMONSTRATION
# ============================================
# Test resilience and recovery

set -e

echo "======================================"
echo "💥 Failure Scenarios Testing"
echo "======================================"

# Scenario 1: Pod Crash
echo ""
echo "📌 SCENARIO 1: Pod Crash & Recovery"
echo "======================================"
echo "Simulating pod crash by deleting one pod..."
POD_NAME=$(kubectl get pods -l app=resilient-spring-platform -o jsonpath='{.items[0].metadata.name}')
echo "Deleting pod: $POD_NAME"
kubectl delete pod $POD_NAME --grace-period=0

echo ""
echo "⏳ Watching recovery (10 seconds)..."
sleep 10

echo ""
echo "✅ Current pod status:"
kubectl get pods -l app=resilient-spring-platform

echo ""
echo "💡 EXPLANATION:"
echo "- Kubernetes detected pod termination"
echo "- Deployment controller created new pod automatically"
echo "- Service continued routing traffic to healthy pods"
echo "- Zero downtime due to replicas=2"
echo ""
read -p "Press Enter to continue to next scenario..."

# Scenario 2: Memory Limit Exceeded
echo ""
echo "📌 SCENARIO 2: Memory Limit Test"
echo "======================================"
echo "Current memory limits:"
kubectl get deployment resilient-spring-platform -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}'
echo ""
echo ""
echo "💡 EXPLANATION:"
echo "- If app exceeds memory limit (512Mi), pod gets OOMKilled"
echo "- Kubernetes automatically restarts the pod"
echo "- Check restart count: kubectl get pods"
echo ""
read -p "Press Enter to continue to next scenario..."

# Scenario 3: Rolling Update
echo ""
echo "📌 SCENARIO 3: Rolling Update (Zero Downtime)"
echo "======================================"
echo "Simulating update by changing environment variable..."
kubectl set env deployment/resilient-spring-platform APP_GREETING_MESSAGE="Updated message v2"

echo ""
echo "⏳ Watching rolling update..."
kubectl rollout status deployment/resilient-spring-platform

echo ""
echo "✅ Rollout completed!"
kubectl get pods -l app=resilient-spring-platform

echo ""
echo "💡 EXPLANATION:"
echo "- Kubernetes created new pods with updated config"
echo "- Waited for readiness probes to pass"
echo "- Terminated old pods gradually"
echo "- maxUnavailable=0 ensured zero downtime"
echo ""
read -p "Press Enter to continue to next scenario..."

# Scenario 4: ConfigMap Change
echo ""
echo "📌 SCENARIO 4: ConfigMap Change"
echo "======================================"
echo "Current ConfigMap:"
kubectl get configmap app-config -o jsonpath='{.data.APP_GREETING_MESSAGE}'
echo ""

echo ""
echo "Updating ConfigMap..."
kubectl patch configmap app-config -p '{"data":{"APP_GREETING_MESSAGE":"Hello from Updated ConfigMap"}}'

echo ""
echo "💡 EXPLANATION:"
echo "- ConfigMap changed but pods did NOT restart automatically"
echo "- Spring Boot doesn't reload config by default"
echo "- Need manual restart: kubectl rollout restart deployment/resilient-spring-platform"
echo ""
echo "To enable dynamic reload, you need:"
echo "  - Spring Cloud Config Server (externalized config)"
echo "  - Reloader Operator (auto-restart on ConfigMap change)"
echo ""
read -p "Press Enter to continue to next scenario..."

# Scenario 5: Liveness Probe Failure
echo ""
echo "📌 SCENARIO 5: Liveness Probe Failure"
echo "======================================"
echo "Liveness probe config:"
kubectl get deployment resilient-spring-platform -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}'
echo ""
echo ""
echo "💡 EXPLANATION:"
echo "- Liveness probe checks: /actuator/health/liveness"
echo "- If fails 3 times (failureThreshold=3), pod restarts"
echo "- Checks every 10 seconds (periodSeconds=10)"
echo "- Grace period: 30 seconds (initialDelaySeconds=30)"
echo ""
echo "To simulate failure (advanced):"
echo "  1. kubectl exec into pod"
echo "  2. Stop Spring Boot process"
echo "  3. Liveness probe fails → Kubernetes restarts pod"
echo ""
read -p "Press Enter to continue to next scenario..."

# Scenario 6: Service Discovery
echo ""
echo "📌 SCENARIO 6: Service Discovery"
echo "======================================"
echo "Service endpoints (pod IPs):"
kubectl get endpoints resilient-spring-platform -o yaml

echo ""
echo "💡 EXPLANATION:"
echo "- Service tracks all healthy pod IPs"
echo "- Only pods passing readiness probe are in endpoints"
echo "- Automatic load balancing between endpoints"
echo "- DNS: resilient-spring-platform.default.svc.cluster.local"
echo ""
read -p "Press Enter to complete testing..."

# Final Status
echo ""
echo "======================================"
echo "📊 FINAL STATUS"
echo "======================================"
kubectl get all -l app=resilient-spring-platform

echo ""
echo "✅ All scenarios completed!"
echo ""
echo "Key Takeaways:"
echo "  1. Kubernetes auto-recovers from pod crashes"
echo "  2. Resource limits prevent resource exhaustion"
echo "  3. Rolling updates enable zero-downtime deployments"
echo "  4. Health probes ensure traffic goes to healthy pods only"
echo "  5. Service discovery is automatic via DNS"
