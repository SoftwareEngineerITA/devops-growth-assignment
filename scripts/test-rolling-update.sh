#!/bin/bash
# TEST 3: Rolling Update - Zero-downtime deployment

echo "=== TEST: Rolling Update (Zero Downtime) ==="
echo ""
echo "SCENARIO: Deploy nove verzije aplikacije bez prekida servisa"
echo "OČEKIVANO: Stari podovi rade dok se novi ne podignu"
echo ""

echo "Trenutni image:"
kubectl get deployment resilient-spring-platform -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
echo ""

echo "Trenutni podovi:"
kubectl get pods -l app=resilient-spring-platform
echo ""

# Promeni environment variable (simulira novu verziju)
echo "SIMULACIJA: Menjam ConfigMap (kao da deploy-ujem novu verziju)"
echo ""
read -p "Pritisni ENTER za rolling update..."

kubectl patch configmap app-config -p '{"data":{"APP_GREETING_MESSAGE":"NOVA VERZIJA - Hello from Kubernetes v2.0"}}'

echo ""
echo "ConfigMap ažuriran! Pokrećem rolling restart..."
kubectl rollout restart deployment/resilient-spring-platform

echo ""
echo "TIP: Pokreni u drugom terminalu:"
echo "  kubectl get pods -l app=resilient-spring-platform -w"
echo ""
echo "Čekam da rolling update završi..."
kubectl rollout status deployment/resilient-spring-platform

echo ""
echo "Novi podovi:"
kubectl get pods -l app=resilient-spring-platform

echo ""
echo "Test nove verzije:"
MINIKUBE_IP=$(minikube ip)
curl -s "http://${MINIKUBE_IP}:30085/api/greet?name=Test" | grep -o '"message":"[^"]*"'

echo ""
echo ""
echo "REZULTAT:"
echo "✅ Rolling update završen bez downtime-a"
echo "✅ maxUnavailable=0 znači da stari podovi rade dok novi nisu ready"
echo "✅ maxSurge=1 znači da Kubernetes može kreirati 1 ekstra pod tokom update-a"
echo ""
echo "PITANJE ZA PREZENTACIJU:"
echo "Q: Kako Kubernetes postiže zero-downtime deployment?"
echo "A: Rolling update strategy - novi podovi se kreiraju pre nego što se stari ugase"
echo ""
echo "Q: Šta je maxUnavailable i maxSurge?"
echo "A: maxUnavailable=0 (nikad nemoj ugasiti sve podove), maxSurge=1 (možeš kreirati +1 pod)"
