#!/bin/bash
# TEST 2: Memory Limit - Šta se dešava kada aplikacija pojede svu memoriju?

echo "=== TEST: OOMKilled (Out of Memory) ==="
echo ""
echo "SCENARIO: Aplikacija troši previše memorije (memory leak, heavy load)"
echo "OČEKIVANO: Kubernetes ubija pod (OOMKilled) i restartuje ga"
echo ""

echo "Trenutni memory limit:"
kubectl get deployment resilient-spring-platform -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}'
echo ""
echo ""

echo "Trenutni podovi:"
kubectl get pods -l app=resilient-spring-platform
echo ""

echo "SIMULACIJA: Spuštam memory limit na 50Mi (aplikaciji treba ~180Mi)"
read -p "Pritisni ENTER za promenu limita..."

kubectl set resources deployment resilient-spring-platform --limits=memory=50Mi

echo ""
echo "Kubernetes pokreće rolling update sa novim limitom..."
echo "Čekam da podovi restartuju..."
sleep 10

echo ""
echo "TIP: Pokreni u drugom terminalu:"
echo "  kubectl get pods -l app=resilient-spring-platform -w"
echo "  kubectl describe pod <pod-name> | grep -A 10 'State'"
echo ""

echo "Provera statusa:"
kubectl get pods -l app=resilient-spring-platform

echo ""
echo "Detalji eventova (traži OOMKilled):"
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i "oom\|killed" | tail -5

echo ""
echo "VRAĆAM NORMALAN LIMIT (512Mi):"
read -p "Pritisni ENTER za vraćanje normalnog limita..."
kubectl set resources deployment resilient-spring-platform --limits=memory=512Mi

echo ""
echo "REZULTAT:"
echo "✅ Pod je ubijen sa statusom OOMKilled (Out of Memory)"
echo "✅ Kubernetes je pokušao da restartuje pod"
echo "✅ CrashLoopBackOff ako memorija nije dovoljna"
echo ""
echo "PITANJE ZA PREZENTACIJU:"
echo "Q: Zašto stavljamo memory limits?"
echo "A: Da spreči da jedna aplikacija pojede sve resurse na node-u (Bulkhead pattern)"
echo ""
echo "Q: Šta je OOMKilled?"
echo "A: Linux kernel ubija proces koji pređe memory limit (Out of Memory Killer)"
