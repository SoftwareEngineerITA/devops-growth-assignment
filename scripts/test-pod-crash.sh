#!/bin/bash
# TEST 1: Pod Crash - Šta se dešava kada pod padne?

echo "=== TEST: Pod Crash & Auto-Recovery ==="
echo ""
echo "SCENARIO: Aplikacija crashuje (greška u kodu, out of memory, etc.)"
echo "OČEKIVANO: Kubernetes automatski kreira novi pod"
echo ""

# Prikaži trenutne podove
echo "Trenutni podovi:"
kubectl get pods -l app=resilient-spring-platform
echo ""

# Uzmi prvi pod
POD=$(kubectl get pods -l app=resilient-spring-platform -o jsonpath='{.items[0].metadata.name}')
echo "Brišem pod: $POD (simulira crash)"
echo ""

# Pokreni watch u drugom terminalu da vidiš šta se dešava
echo "TIP: Otvori drugi terminal i pokreni:"
echo "  kubectl get pods -l app=resilient-spring-platform -w"
echo ""
read -p "Pritisni ENTER za brisanje poda..."

kubectl delete pod $POD

echo ""
echo "Pod obrisan! Čekam 5 sekundi..."
sleep 5

echo ""
echo "Novi status:"
kubectl get pods -l app=resilient-spring-platform

echo ""
echo "REZULTAT:"
echo "✅ Kubernetes je automatski kreirao novi pod"
echo "✅ Aplikacija je i dalje dostupna (drugi pod radi)"
echo ""
echo "PITANJE ZA PREZENTACIJU:"
echo "Q: Šta se dešava ako pod crashuje?"
echo "A: Kubernetes Deployment održava desired state (2 replicas), automatski kreira novi pod"
