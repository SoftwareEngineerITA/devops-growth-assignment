#!/bin/bash
# TEST 5: Liveness vs Readiness Probe - Koja je razlika?

echo "=== TEST: Liveness vs Readiness Probe ==="
echo ""
echo "SCENARIO: Razlika između 2 tipa health check-ova"
echo ""

POD=$(kubectl get pods -l app=resilient-spring-platform -o jsonpath='{.items[0].metadata.name}')

echo "Testiram pod: $POD"
echo ""

echo "1. LIVENESS PROBE"
echo "   - Endpoint: /actuator/health/liveness"
echo "   - Svrha: Detektuje da li je aplikacija 'živa' (ne deadlock)"
echo "   - Akcija: Ako fail → Kubernetes RESTARTUJE POD"
echo ""

echo "   Test liveness probe:"
LIVENESS=$(kubectl exec $POD -- wget -q -O - http://localhost:8080/actuator/health/liveness)
echo "   Response: $LIVENESS"

echo ""
echo "   Konfiguracija:"
kubectl get deployment resilient-spring-platform -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' | jq .
echo ""

echo ""
echo "2. READINESS PROBE"
echo "   - Endpoint: /actuator/health/readiness"
echo "   - Svrha: Detektuje da li je aplikacija 'spremna' za traffic"
echo "   - Akcija: Ako fail → Kubernetes UKLANJA IZ SERVICE (ali ne restartuje)"
echo ""

echo "   Test readiness probe:"
READINESS=$(kubectl exec $POD -- wget -q -O - http://localhost:8080/actuator/health/readiness)
echo "   Response: $READINESS"

echo ""
echo "   Konfiguracija:"
kubectl get deployment resilient-spring-platform -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' | jq .
echo ""

echo ""
echo "DEMONSTRACIJA RAZLIKE:"
echo ""
echo "Scenario A: LIVENESS FAILS"
echo "  - Aplikacija je u deadlock-u (ne odgovara)"
echo "  - Liveness probe timeout nakon 3 failureThreshold"
echo "  - Kubernetes RESTARTUJE POD"
echo "  - Readiness probe automatski fail tokom restart-a (ne prima traffic)"
echo ""

echo "Scenario B: READINESS FAILS"
echo "  - Aplikacija se podiže (startup), ili database nije dostupan"
echo "  - Readiness probe fails"
echo "  - Kubernetes NE ŠALJE TRAFFIC ovom podu"
echo "  - Liveness probe je i dalje OK (pod ne restartuje)"
echo "  - Kada readiness pređe u OK, Service ponovo šalje traffic"
echo ""

echo "PROVERA STATUSA:"
kubectl describe pod $POD | grep -A 5 "Liveness:\|Readiness:"

echo ""
echo ""
echo "PITANJE ZA PREZENTACIJU:"
echo ""
echo "Q: Koja je razlika između Liveness i Readiness probe?"
echo "A: "
echo "   - Liveness = 'Da li je app živ?' (deadlock detection) → restart pod"
echo "   - Readiness = 'Da li je app spreman?' (startup, dependencies) → ne šalji traffic"
echo ""
echo "Q: Zašto trebaju OBA probe-a?"
echo "A: "
echo "   - Readiness štiti od slanja traffic-a tokom startup-a (app se podiže 10s)"
echo "   - Liveness detektuje deadlock (app je 'živ' ali ne radi - ne odgovara)"
echo ""
echo "Q: Šta je initialDelaySeconds?"
echo "A: Koliko sekundi čekati pre prvog probe-a (aplikacija treba vreme za startup)"
echo ""
echo "PRIMER IZ NAŠE APLIKACIJE:"
echo "  - Liveness: initialDelay=30s (čekaj 30s da app starta), period=10s"
echo "  - Readiness: initialDelay=20s (brži check), period=5s"
echo "  - Spring Boot app startup: ~7-10s"
