# 🎤 PRESENTATION SCRIPT - Individual Development Assignment
**Duration:** 30 minutes  
**Audience:** Line Manager (Dunja)  
**Objective:** Demonstrate growth from Java Developer → DevOps fundamentals

---

## 📋 PREPARATION CHECKLIST (Before Presentation)

### ✅ Terminal Setup
- [ ] WSL terminal open (`wsl -d Ubuntu`)
- [ ] Navigate to project: `cd ~/devops-demo`
- [ ] minikube running: `minikube status`
- [ ] Pods deployed: `kubectl get pods -n resilient-dev`

### ✅ Browser Tabs Ready
- [ ] Tab 1: `http://$(minikube ip):30081/actuator/health`
- [ ] Tab 2: Architecture diagram (if you have one)
- [ ] Tab 3: GitHub repository

### ✅ Files Open in VS Code
- [ ] `Dockerfile`
- [ ] `k8s/deployment.yaml`
- [ ] `k8s/service.yaml`

---

## SECTION 1: INTRODUCTION & OVERVIEW (3-4 minutes)

### 🗣️ What You Say

Good afternoon! Thank you for this opportunity.

Over the past month, I've been working on this individual development assignment, and the goal was clear: demonstrate practical growth from a Java-focused role toward DevOps fundamentals.

This isn't just about learning tools. The real challenge was to understand **how a Java application actually runs in a production-like environment** - from code, to container, to Kubernetes cluster, and how it behaves when things go wrong.

**What I Built:**
- A Spring Boot REST application with production readiness in mind
- Docker containerization using multi-stage builds
- Kubernetes deployment with proper configuration management
- Basic failure handling and self-healing capabilities

The entire system is end-to-end: I can build it, deploy it, and explain every decision along the way.

**Presentation Structure:**
Today I'll walk you through five key areas:
1. Architecture overview - design decisions
2. Application lifecycle - from source code to running pod
3. Configuration management - how we inject config without hardcoding
4. Failure scenarios - what happens when things break
5. Key lessons I learned

Let's dive in.

### 📺 What You Show
- (Optional) Briefly show GitHub repository structure
- (Optional) Quick `tree` view of project folders

### 💡 Key Points to Emphasize
- **Not just tool knowledge** - understanding production mindset
- **End-to-end ownership** - build, deploy, debug
- **Growth mindset** - Java developer learning infrastructure

---

## SECTION 2: ARCHITECTURE OVERVIEW (5-6 minutes)

### 🗣️ What You Say

Let me start with the architecture and the design decisions I made.

**Application Layer:**
I built a Spring Boot REST application - intentionally kept simple because the focus wasn't on complex business logic, but on **production readiness**.

Key features:
- REST endpoint (`/api/status`) - demonstrates application is responding
- Spring Boot Actuator health endpoints - `/actuator/health`, `/actuator/health/liveness`, `/actuator/health/readiness`
- Externalized configuration - no hardcoded values

**Why Spring Boot Actuator?**
In production, Kubernetes needs to know: "Is this application alive?" and "Is it ready to serve traffic?" Actuator provides standardized health checks that Kubernetes can consume.

**Containerization Layer:**
I dockerized the application using a **multi-stage build**.

Let me show you the Dockerfile briefly:

### 📺 What You Show
```bash
# Open Dockerfile in VS Code
# Scroll through and highlight:
```

### 🗣️ What You Say (pointing at Dockerfile)

Stage 1 (Builder):
- Uses Maven to compile and package the application
- Produces the JAR file
- This stage includes JDK and Maven - tools we DON'T need in production

Stage 2 (Runtime):
- Uses lightweight JRE image (not JDK)
- Copies ONLY the JAR file from Stage 1
- Runs as non-root user (appuser) for security
- Final image: ~250MB vs 600MB+ if we included build tools

**Why multi-stage?**
- Smaller image = faster deployments, lower storage costs
- No build tools in production = reduced attack surface
- Clean separation between build and runtime

**Kubernetes Layer:**
The application runs on Kubernetes with these resources:

### 📺 What You Show
```bash
# Terminal:
kubectl get all -n resilient-dev
```

### 🗣️ What You Say

- **Deployment:** Manages 2 pod replicas for high availability
- **Service:** Exposes the application (NodePort for local testing)
- **ConfigMap:** External configuration (greeting message, environment name)
- **Secret:** Sensitive data (database password - base64 encoded)

**Why 2 replicas?**
If one pod crashes, the second continues serving traffic. Zero downtime. Kubernetes automatically creates a new pod to replace the failed one.

**Architecture Decision:**
I chose NodePort Service type for local testing. In a real cloud production environment, I'd use:
- **LoadBalancer** type (AWS ELB, Azure Load Balancer), OR
- **ClusterIP** with an Ingress controller (for HTTP/HTTPS routing)

The key principle: **Separate infrastructure configuration from application code**. The app doesn't know it's running on Kubernetes. It just reads environment variables.

### 💡 Key Points to Emphasize
- Multi-stage build = production optimization
- 2 replicas = high availability
- Actuator endpoints = Kubernetes integration
- Externalized config = 12-Factor App principles

---

## SECTION 3: APPLICATION LIFECYCLE (6-7 minutes)

### 🗣️ What You Say

Now let me walk you through the complete lifecycle - from source code to running pod.

**Step 1: Build the Application**

### 📺 What You Show (don't actually run if already built, just explain)
```bash
# Show the command (don't run unless needed):
cd ~/devops-demo
mvn clean package
```

### 🗣️ What You Say

Maven compiles the Java code, runs tests, and produces a JAR file in `target/` directory.

**Step 2: Build Docker Image**

### 📺 What You Show
```bash
# Show the command:
docker build -t resilient-spring-platform:1.0.0 .
```

### 🗣️ What You Say

This executes the multi-stage Dockerfile:
- Builder stage: Maven build inside container (reproducible environment)
- Runtime stage: JRE + JAR
- Tagged as version 1.0.0

**Step 3: Deploy to Kubernetes**

### 📺 What You Show
```bash
# Show deployment files:
ls -l k8s/

# Apply manifests:
kubectl apply -f k8s/
```

### 🗣️ What You Say

`kubectl apply` reads the YAML manifests and creates:
- Deployment resource (desired state: 2 replicas)
- Service resource (network routing)
- ConfigMap and Secret (configuration injection)

Kubernetes **reconciliation loop** kicks in:
- "I need 2 pods running"
- Creates pod 1, pod 2
- Pulls Docker image
- Starts containers
- Waits for readiness probe

**Step 4: Verify Deployment**

### 📺 What You Show
```bash
# Check pods:
kubectl get pods -n resilient-dev -o wide

# Check service:
kubectl get svc -n resilient-dev

# Test application:
curl http://$(minikube ip):30081/api/status
```

### 🗣️ What You Say (while showing output)

Pods are **Running** and **Ready** (1/1).
- Running = container process is alive
- Ready = readiness probe passed, pod is receiving traffic

Service exposes NodePort 30081 - we can access the app externally.

Let me show you the application responding:

### 📺 What You Show
```bash
# Call API:
curl http://$(minikube ip):30081/api/status | jq .

# Or open in browser
```

### 🗣️ What You Say

The application is serving traffic. Notice the response includes environment variables we injected from ConfigMap.

**Step 5: Configuration Injection**

Let me show you HOW the configuration gets into the pod.

### 📺 What You Show
```bash
# Exec into pod:
kubectl exec -it <pod-name> -n resilient-dev -- sh

# Inside pod:
env | grep APP
```

### 🗣️ What You Say

ConfigMap values are injected as environment variables. The application reads them at startup.

This is the 12-Factor App principle: **Config should be environment-specific, not hardcoded**.

Same Docker image runs in dev, staging, production - only the ConfigMap changes.

### 📺 What You Show
```bash
# Exit pod:
exit
```

### 💡 Key Points to Emphasize
- **Reproducible builds** (Docker ensures consistent environment)
- **Declarative deployment** (YAML defines desired state)
- **Configuration injection** (environment-specific without code changes)
- **Verification steps** (always check deployment status)

---

## SECTION 4: FAILURE SCENARIOS & RECOVERY (8-10 minutes)

### 🗣️ What You Say

This is where Kubernetes really shines - **self-healing**. Let me demonstrate what happens when things go wrong.

**Scenario 1: Pod Crashes**

In production, pods can crash for many reasons: application bug, out of memory, process killed. Let's simulate this.

### 📺 What You Show
```bash
# Terminal 1 - Watch pods:
kubectl get pods -n resilient-dev -w
```

### 🗣️ What You Say

I'm watching pods in real-time. Now in another terminal, I'll delete a pod to simulate a crash.

### 📺 What You Show
```bash
# Terminal 2 - Delete pod:
kubectl delete pod <pod-name> -n resilient-dev
```

### 🗣️ What You Say (while watching Terminal 1)

Watch what happens:
1. Pod status changes to **Terminating**
2. Kubernetes Deployment controller detects: "I have 1 pod, but I need 2"
3. Immediately creates a new pod (**Pending**)
4. New pod transitions: Pending → ContainerCreating → Running
5. Readiness probe checks the new pod (takes ~20 seconds)
6. Once ready, Service adds it to the endpoint list

**Result:** Zero manual intervention. Kubernetes automatically maintains the desired state.

During this entire process, the second pod was still serving traffic - **zero downtime**.

### 📺 What You Show
```bash
# Verify pods are back to 2/2:
kubectl get pods -n resilient-dev
```

---

**Scenario 2: Liveness vs Readiness Probes**

Let me explain the difference - this is a production-critical concept.

### 🗣️ What You Say

**Liveness Probe** asks: "Is the application alive?"
- Checks: `/actuator/health/liveness`
- If it fails 3 times → Kubernetes **restarts the pod**
- Use case: Application is deadlocked or hung

**Readiness Probe** asks: "Is the application ready for traffic?"
- Checks: `/actuator/health/readiness`
- If it fails → Kubernetes **removes pod from Service** (but doesn't restart!)
- Use case: Application is starting up, or dependency (database) is unavailable

### 📺 What You Show (optional - if time permits)
```bash
# Show probe configuration in deployment.yaml
# Highlight initialDelaySeconds, periodSeconds, failureThreshold
```

### 🗣️ What You Say

Why `initialDelaySeconds: 20` for readiness?
- Spring Boot takes 15-20 seconds to start
- If we check immediately, probe fails → pod never becomes Ready → restart loop!

This is a common mistake in production. You need to give the application time to initialize.

---

**Scenario 3: Resource Limits & OOMKilled**

Let me show you the resource configuration.

### 📺 What You Show
```bash
# Show in deployment.yaml:
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 🗣️ What You Say

**Requests** = guaranteed minimum. Kubernetes won't schedule the pod on a node unless these resources are available.

**Limits** = maximum allowed. If the pod exceeds:
- CPU limit → throttled (slows down, not killed)
- Memory limit → **OOMKilled** (Out Of Memory - pod is killed and restarted)

Why set limits?
- Prevents one pod from consuming all node resources
- "Noisy neighbor" problem - one misbehaving app crashes the entire node
- Enables autoscaling (HPA - Horizontal Pod Autoscaler)

In production, I'd monitor actual usage and adjust these values.

---

**Scenario 4: Rolling Update (Zero Downtime Deployment)**

Finally, let me show you how we deploy new versions without downtime.

### 🗣️ What You Say

The deployment strategy is configured as **RollingUpdate** with:
- `maxUnavailable: 0` - never go below 2 running pods
- `maxSurge: 1` - can temporarily have 3 pods during update

Let's simulate a new version deployment.

### 📺 What You Show
```bash
# Update image to new version:
kubectl set image deployment/resilient-spring-platform app=resilient-spring-platform:2.0.0 -n resilient-dev

# Watch rollout:
kubectl rollout status deployment/resilient-spring-platform -n resilient-dev
```

### 🗣️ What You Say (explain as it happens)

Kubernetes process:
1. Creates 1 new pod with version 2.0.0
2. Waits for readiness probe to pass
3. Once ready, terminates 1 old pod
4. Repeats until all pods are new version

During the entire process:
- At least 2 pods are always Running and Ready
- Service continuously routes traffic
- **Zero downtime!**

If the new version has a bug and readiness probe fails → rollout stops automatically.

### 📺 What You Show
```bash
# Check rollout history:
kubectl rollout history deployment/resilient-spring-platform -n resilient-dev

# Rollback (if needed):
# kubectl rollout undo deployment/resilient-spring-platform -n resilient-dev
```

### 💡 Key Points to Emphasize
- **Self-healing** - Kubernetes automatically recovers from failures
- **Probes are critical** - wrong configuration = restart loops
- **Resource limits** - production stability requirement
- **Rolling updates** - zero downtime deployments

---

## SECTION 5: LESSONS LEARNED & PRODUCTION MINDSET (4-5 minutes)

### 🗣️ What You Say

Let me wrap up with the key lessons I learned through this assignment.

**1. Separation of Concerns**

The application doesn't know it's running on Kubernetes. It just reads environment variables and responds to HTTP health checks.

This separation means:
- Same Docker image runs everywhere (dev, staging, prod)
- Configuration changes don't require rebuilds
- Easier testing (can run locally without K8s)

**2. Declarative Infrastructure**

The YAML manifests define **desired state**, not imperative commands.

I don't say: "Start 2 pods, wait, start a service..."
I say: "I want 2 pods running. Kubernetes, make it happen."

This is powerful because Kubernetes continuously reconciles. If something drifts from desired state, it auto-corrects.

**3. Production Readiness != Feature Completeness**

The application itself is simple. But production readiness means:
- Health endpoints for monitoring
- Resource limits to prevent resource exhaustion
- Non-root user for security
- Externalized config for environment flexibility
- Proper logging (stdout/stderr - Kubernetes captures it)

**4. Failure is Normal**

In a distributed system, failures happen constantly:
- Pods crash
- Nodes go down
- Networks partition

The mindset shift: Don't try to prevent all failures. **Design for graceful degradation**.

With 2 replicas, one can fail and traffic continues. Kubernetes automatically recovers.

**5. Observability Matters**

During development, I constantly checked:
- Pod status: `kubectl get pods`
- Logs: `kubectl logs <pod>`
- Events: `kubectl describe pod <pod>`
- Health endpoints: `curl /actuator/health`

In production, this would be:
- Prometheus for metrics
- ELK/EFK for centralized logging
- Grafana for dashboards
- Alerting (PagerDuty, Slack)

But the principle is the same: **You can't fix what you can't see**.

**6. Trade-offs Everywhere**

Every decision has trade-offs:
- 2 replicas = high availability, but 2x cost
- Resource limits = stability, but might throttle legitimate spikes
- NodePort = easy local testing, but not production-grade (need LoadBalancer/Ingress)

Senior mindset: Understanding these trade-offs and making informed decisions based on context.

**What I Would Do Differently / Next Steps:**

If this were a real production system:
- **CI/CD pipeline** - automate build → test → deploy
- **Helm charts** - template Kubernetes manifests for multiple environments
- **Ingress controller** - proper HTTP routing, SSL termination
- **Monitoring stack** - Prometheus + Grafana
- **Secret management** - External Secrets Operator (not base64 in Git!)
- **Network policies** - pod-to-pod communication restrictions
- **Database** - persistent storage, backups

But for this assignment, the goal was to demonstrate foundational understanding - and I believe I've achieved that.

### 💡 Key Points to Emphasize
- **Growth mindset** - Java developer learning infrastructure
- **Production awareness** - it's not just about "making it work"
- **Trade-offs** - every decision has pros and cons
- **Continuous learning** - there's always more to learn

---

## CLOSING (1-2 minutes)

### 🗣️ What You Say

To summarize:

I've demonstrated a complete end-to-end system:
✅ Spring Boot application with production readiness
✅ Docker containerization with optimization (multi-stage build)
✅ Kubernetes deployment with proper config management
✅ Failure handling and self-healing

More importantly, I've shown **how I think** about:
- Design decisions (why 2 replicas? why multi-stage?)
- Production concerns (probes, resource limits, security)
- Failure scenarios (what happens when things break?)

This assignment has been an excellent learning experience. I now understand not just "how to deploy an app," but **what it takes to run it reliably in production**.

Thank you! I'm happy to answer any questions or dive deeper into any area.

---

## 📝 POSSIBLE QUESTIONS & ANSWERS

### Q: Why did you choose Spring Boot?
**A:** Familiarity (I'm a Java developer) + built-in Actuator for health endpoints. Actuator integrates seamlessly with Kubernetes probes - this is production-ready by default.

### Q: How would you handle secrets in production?
**A:** Current setup (base64 in Git) is NOT production-safe. I'd use External Secrets Operator with AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault. Secrets stored encrypted externally, synced into K8s at runtime.

### Q: What if the database goes down?
**A:** Readiness probe would fail (app can't serve requests without DB). Kubernetes removes pod from Service endpoints. Once DB is back, readiness passes, pod returns to rotation. No restart needed.

### Q: How would you scale this application?
**A:** Horizontal Pod Autoscaler (HPA) based on CPU/memory metrics. For example: "If CPU > 70%, scale from 2 to 5 pods." HPA adjusts replicas automatically. Also consider Cluster Autoscaler to add nodes if needed.

### Q: What about logging?
**A:** Currently logs to stdout/stderr - Kubernetes captures this. In production, I'd use a logging stack (Fluentd/Fluent Bit → Elasticsearch → Kibana) to aggregate logs from all pods. Centralized, searchable, with retention policies.

### Q: How do you troubleshoot a failing pod?
**A:**
1. `kubectl get pods` - check status (CrashLoopBackOff, OOMKilled, etc.)
2. `kubectl logs <pod>` - application logs
3. `kubectl describe pod <pod>` - events (why it failed)
4. `kubectl exec -it <pod> -- sh` - exec into container (if running)
5. Check resource usage: `kubectl top pods`

### Q: Why NodePort instead of LoadBalancer?
**A:** NodePort is sufficient for local testing (minikube). LoadBalancer requires cloud provider (AWS, Azure, GCP). In production, I'd use LoadBalancer or Ingress for proper external access with SSL termination.

### Q: What happens during a node failure?
**A:** Kubernetes detects node is unresponsive. Reschedules pods from failed node to healthy nodes. With 2 replicas on different nodes (anti-affinity), one pod survives, maintains service. New pod created on healthy node.

### Q: How would you implement CI/CD?
**A:** GitHub Actions or Jenkins:
1. Code push → trigger pipeline
2. Run tests (unit, integration)
3. Build Docker image, tag with Git SHA
4. Push to registry (Docker Hub, ECR)
5. Update Kubernetes Deployment with new image
6. Rolling update with health checks
7. Rollback if health checks fail

---

## ⏱️ TIMING GUIDE

| Section | Duration | Focus |
|---------|----------|-------|
| Introduction | 3-4 min | Set context, outline structure |
| Architecture | 5-6 min | Design decisions, show code |
| Lifecycle | 6-7 min | Build → Deploy → Verify |
| Failure Scenarios | 8-10 min | Live demos (pod crash, probes, rolling update) |
| Lessons Learned | 4-5 min | Mindset, trade-offs, next steps |
| Closing + Q&A | 2-3 min | Summary, open for questions |
| **TOTAL** | **28-35 min** | **Flexible based on questions** |

---

## 🎯 FINAL CHECKLIST (Day Before)

- [ ] Practice presentation 2-3 times (with timer!)
- [ ] Verify all commands work
- [ ] Clean up workspace (delete old pods, restart minikube)
- [ ] Prepare for questions (read Q&A section)
- [ ] Get good sleep! 😴

---

**Good luck! You've got this!** 🚀🔥
