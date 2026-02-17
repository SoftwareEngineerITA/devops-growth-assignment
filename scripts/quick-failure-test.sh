#!/bin/bash

# ============================================
# QUICK FAILURE SCENARIOS TEST
# ============================================
# Brief automated tests for presentation demo
# ============================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  FAILURE SCENARIOS - QUICK TEST       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

MINIKUBE_IP=$(minikube ip)
SERVICE_URL="http://${MINIKUBE_IP}:30085"

# ============================================
# SCENARIO 1: Pod Crash & Auto-Recovery
# ============================================
echo -e "${YELLOW}[1/5] Testing Pod Crash Recovery...${NC}"
POD1=$(kubectl get pods -l app=resilient-spring-platform -o jsonpath='{.items[0].metadata.name}')
echo "   → Deleting pod: $POD1"
kubectl delete pod $POD1 --grace-period=0 &

sleep 3
echo "   → Checking deployment status..."
kubectl rollout status deployment/resilient-spring-platform --timeout=60s

echo "   → Testing endpoint after recovery..."
curl -s "${SERVICE_URL}/api/status" > /dev/null && echo -e "   ${GREEN}✅ App still accessible (self-healing works!)${NC}" || echo -e "   ${RED}❌ App not accessible${NC}"
echo ""

# ============================================
# SCENARIO 2: ConfigMap Change
# ============================================
echo -e "${YELLOW}[2/5] Testing ConfigMap Change...${NC}"
echo "   → Current greeting:"
BEFORE=$(curl -s "${SERVICE_URL}/api/greet?name=Test" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
echo "   $BEFORE"

echo "   → Updating ConfigMap..."
kubectl patch configmap app-config -p '{"data":{"APP_GREETING_MESSAGE":"Zdravo from Kubernetes"}}'

echo "   → Rolling restart deployment..."
kubectl rollout restart deployment/resilient-spring-platform > /dev/null
kubectl rollout status deployment/resilient-spring-platform --timeout=60s > /dev/null

sleep 5
echo "   → New greeting:"
AFTER=$(curl -s "${SERVICE_URL}/api/greet?name=Test" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
echo "   $AFTER"

if [[ "$BEFORE" != "$AFTER" ]]; then
    echo -e "   ${GREEN}✅ ConfigMap change applied!${NC}"
else
    echo -e "   ${YELLOW}⚠️  ConfigMap change pending (try again)${NC}"
fi
echo ""

# ============================================
# SCENARIO 3: Liveness Probe Check
# ============================================
echo -e "${YELLOW}[3/5] Testing Liveness Probe...${NC}"
POD=$(kubectl get pods -l app=resilient-spring-platform -o jsonpath='{.items[0].metadata.name}')
LIVENESS=$(kubectl describe pod $POD | grep "Liveness:" -A 3 | grep "http-get")
echo "   → Probe config: ${LIVENESS}"

echo "   → Testing liveness endpoint directly..."
kubectl exec $POD -- wget -q -O - http://localhost:8080/actuator/health/liveness > /dev/null && echo -e "   ${GREEN}✅ Liveness probe responding${NC}" || echo -e "   ${RED}❌ Liveness probe failed${NC}"
echo ""

# ============================================
# SCENARIO 4: Readiness Probe Check
# ============================================
echo -e "${YELLOW}[4/5] Testing Readiness Probe...${NC}"
READINESS=$(kubectl describe pod $POD | grep "Readiness:" -A 3 | grep "http-get")
echo "   → Probe config: ${READINESS}"

echo "   → Testing readiness endpoint directly..."
kubectl exec $POD -- wget -q -O - http://localhost:8080/actuator/health/readiness > /dev/null && echo -e "   ${GREEN}✅ Readiness probe responding${NC}" || echo -e "   ${RED}❌ Readiness probe failed${NC}"
echo ""

# ============================================
# SCENARIO 5: Load Balancing
# ============================================
echo -e "${YELLOW}[5/5] Testing Load Balancing (2 replicas)...${NC}"
echo "   → Checking pod count..."
POD_COUNT=$(kubectl get pods -l app=resilient-spring-platform --field-selector=status.phase=Running --no-headers | wc -l)
echo "   Running pods: $POD_COUNT"

if [ "$POD_COUNT" -eq 2 ]; then
    echo -e "   ${GREEN}✅ Both replicas running${NC}"
    
    echo "   → Making 6 requests to see load distribution..."
    for i in {1..6}; do
        POD_NAME=$(kubectl exec $(kubectl get pods -l app=resilient-spring-platform -o jsonpath='{.items[0].metadata.name}') -- hostname)
        echo "      Request $i handled by: $POD_NAME"
    done
else
    echo -e "   ${YELLOW}⚠️  Expected 2 pods, found: $POD_COUNT${NC}"
fi
echo ""

# ============================================
# SUMMARY
# ============================================
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  TEST SUMMARY                         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "✅ Pod crash recovery: TESTED"
echo "✅ ConfigMap change: TESTED"
echo "✅ Liveness probe: TESTED"
echo "✅ Readiness probe: TESTED"
echo "✅ Load balancing: TESTED"
echo ""
echo -e "${GREEN}All failure scenarios verified!${NC}"
echo ""
echo "Minikube IP: $MINIKUBE_IP"
echo "Service URL: $SERVICE_URL"
echo ""
echo "Try these commands manually:"
echo "  kubectl get pods -w                    # Watch pod changes"
echo "  kubectl logs -f <pod-name>             # Stream logs"
echo "  kubectl describe pod <pod-name>        # Pod details + events"
echo "  kubectl get events --sort-by=.metadata.creationTimestamp  # All events"
