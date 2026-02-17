# 🚀 Resilient Spring Platform

**DevOps Upskilling Project - Java Developer → DevOps Growth Path**

Production-ready Spring Boot application demonstrating containerization, Kubernetes deployment, and production best practices.

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Build & Run](#build--run)
- [Docker](#docker)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Configuration Management](#configuration-management)
- [Production Readiness](#production-readiness)
- [Failure Scenarios](#failure-scenarios)
- [Lessons Learned](#lessons-learned)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │              Service (LoadBalancer)               │ │
│  │          resilient-spring-platform:80             │ │
│  └─────────────────┬───────────────────────────────┬─┘ │
│                    │                               │   │
│  ┌─────────────────▼────────┐  ┌───────────────────▼───┐ │
│  │      Pod 1 (Replica 1)   │  │   Pod 2 (Replica 2)   │ │
│  │  ┌────────────────────┐  │  │  ┌────────────────────┐│ │
│  │  │  Spring Boot App   │  │  │  │  Spring Boot App   ││ │
│  │  │  Port: 8080        │  │  │  │  Port: 8080        ││ │
│  │  └────────────────────┘  │  │  └────────────────────┘│ │
│  │  Liveness Probe: ✓       │  │  Liveness Probe: ✓     │ │
│  │  Readiness Probe: ✓      │  │  Readiness Probe: ✓    │ │
│  └──────────────────────────┘  └────────────────────────┘ │
│                    │                               │   │
│  ┌─────────────────▼───────────────────────────────▼─┐ │
│  │           ConfigMap (app-config)                  │ │
│  │  - APP_GREETING_MESSAGE                           │ │
│  │  - APP_ENVIRONMENT                                │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │           Secret (app-secret)                     │ │
│  │  - DATABASE_PASSWORD (base64)                     │ │
│  │  - API_KEY (base64)                               │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Language:** Java 21
- **Framework:** Spring Boot 3.2.1
- **Build Tool:** Maven
- **Containerization:** Docker (Multi-stage build)
- **Orchestration:** Kubernetes
- **Base Image:** Eclipse Temurin (Alpine Linux)

---

## ✅ Prerequisites

### Required:
- **Java 21** (JDK)
- **Maven 3.8+** (or use included Maven wrapper)
- **Docker Desktop** (with Kubernetes enabled)
- **kubectl** (Kubernetes CLI)
- **Git**

### Verification:
```bash
java -version      # Java 21+
mvn -version       # Maven 3.8+
docker --version   # Docker 20.10+
kubectl version    # Kubernetes CLI
```

---

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd resilient-spring-platform
```

### 2. Build Application
```bash
# Using Maven wrapper (recommended)
./mvnw clean package

# Or using system Maven
mvn clean package
```

### 3. Run Locally (without Docker)
```bash
java -jar target/resilient-spring-platform.jar

# Test endpoint
curl http://localhost:8080/api/greet?name=DevOps
curl http://localhost:8080/actuator/health
```

---

## 🐳 Docker

### Build Docker Image

**PRO TIP:** Multi-stage build optimization

```bash
docker build -t resilient-spring-platform:1.0.0 .
```

**Q:** How long does the first build take vs. second build?
**A:** First build = ~3-5 min (downloads dependencies), Second build = ~30s (cached!)

### Run Docker Container

```bash
docker run -d \
  --name spring-app \
  -p 8080:8080 \
  -e APP_GREETING_MESSAGE="Hello from Docker" \
  -e APP_ENVIRONMENT="docker-local" \
  resilient-spring-platform:1.0.0
```

### Test Container
```bash
curl http://localhost:8080/api/greet?name=Docker

# Check container logs
docker logs spring-app

# Check container health
docker inspect --format='{{.State.Health.Status}}' spring-app
```

### Docker Image Analysis

**Q:** How large is the final image?
```bash
docker images resilient-spring-platform:1.0.0

# Expected: ~200-250MB (JRE + Alpine + JAR)
# Without multi-stage: ~800MB+ (JDK + Maven + cache)
```

---

## ☸️ Kubernetes Deployment

### Prerequisites: Docker Desktop Kubernetes

1. **Enable Kubernetes** in Docker Desktop settings
2. **Verify context:**
   ```bash
   kubectl config current-context
   # Should show: docker-desktop
   ```

### Deploy to Kubernetes

#### Step 1: Load Docker Image into Kubernetes
```bash
# Docker Desktop automatically sees local images
# Verification:
docker images | grep resilient-spring-platform
```

#### Step 2: Apply Kubernetes Manifests
```bash
# Apply all manifests at once
kubectl apply -f k8s/

# Or one by one (for learning):
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

#### Step 3: Verify Deployment
```bash
# Check resources
kubectl get all

# Check pods
kubectl get pods -o wide

# Check service
kubectl get svc resilient-spring-platform

# Check configuration
kubectl get configmap app-config -o yaml
kubectl get secret app-secret -o yaml
```

#### Step 4: Test Application
```bash
# NodePort access (Docker Desktop)
curl http://localhost:30080/api/greet?name=Kubernetes

# Port-forward alternative
kubectl port-forward svc/resilient-spring-platform 8080:80
curl http://localhost:8080/api/greet?name=K8s
```

---

## ⚙️ Configuration Management

### Environment Variables Hierarchy

**Priority (highest to lowest):**
1. **Kubernetes Secret/ConfigMap** (Production)
2. **Environment Variables** (Docker/OS)
3. **application.properties** (Default values)

### Example: Change Greeting Message

#### Option 1: Edit ConfigMap
```bash
kubectl edit configmap app-config

# Change: APP_GREETING_MESSAGE: "Hello from K8s"

# Restart pods to reload
kubectl rollout restart deployment/resilient-spring-platform
```

#### Option 2: Apply New ConfigMap
```yaml
# k8s/configmap.yaml
data:
  APP_GREETING_MESSAGE: "Updated!"
```
```bash
kubectl apply -f k8s/configmap.yaml
kubectl rollout restart deployment/resilient-spring-platform
```

**Q:** Why is restart required?
**A:** Spring Boot doesn't watch ConfigMap changes automatically. For dynamic reload, use Spring Cloud Config Server or sidecar pattern.

---

## 🛡️ Production Readiness

### Resource Management

**CPU and Memory Limits are defined in deployment.yaml:**

```yaml
resources:
  requests:
    cpu: 100m      # Guaranteed minimum
    memory: 256Mi
  limits:
    cpu: 500m      # Maximum
    memory: 512Mi
```

**Q:** What happens if the app exceeds the limit?
**A:**
- **CPU:** Throttling (slowdown, not killed)
- **Memory:** OOMKilled (pod is restarted)

### Health Probes

#### Liveness Probe
```bash
# Direktan test
curl http://localhost:8080/actuator/health/liveness

# Expected: {"status":"UP"}
```

**What it does:** If 3x fail → K8s restarts pod

#### Readiness Probe
```bash
curl http://localhost:8080/actuator/health/readiness
```

**What it does:** If fail → Pod is removed from Service load balancing

### Security

✅ **Non-root user** (UID 1001)  
✅ **Read-only filesystem** (gde je moguće)  
✅ **Minimal base image** (Alpine Linux)  
✅ **No hardcoded secrets**  
✅ **Resource limits** (anti DoS)

---

## 💥 Failure Scenarios

### Scenario 1: Pod Crashes

**Simulation:**
```bash
# Kill pod
kubectl delete pod -l app=resilient-spring-platform --grace-period=0

# Watch recovery
kubectl get pods -w
```

**What happens:**
1. Liveness probe fails
2. K8s creates new pod (replicas=2 config)
3. Service automatically routes traffic to healthy pod
4. **Downtime:** ~0-5s (due to replicas=2)

### Scenario 2: Memory Leak (OOMKill)

**Simulation:**
```bash
# Reduce memory limit
kubectl set resources deployment/resilient-spring-platform \
  --limits=memory=128Mi

# Increase load
for i in {1..100}; do curl http://localhost:30080/api/greet?name=Test$i; done
```

**What happens:**
1. Memory usage increases
2. Exceeds 128Mi limit
3. OOMKilled
4. K8s restarts pod
5. Check events: `kubectl describe pod <pod-name>`

### Scenario 3: Rolling Update

**Simulation:**
```bash
# Change image tag
kubectl set image deployment/resilient-spring-platform \
  app=resilient-spring-platform:2.0.0

# Watch rollout
kubectl rollout status deployment/resilient-spring-platform
```

**What happens:**
1. K8s creates new pod (v2.0.0)
2. Waits for readiness probe
3. New pod becomes healthy
4. K8s routes traffic to new pod
5. Old pod terminates (graceful shutdown)
6. **maxUnavailable=0** = ZERO DOWNTIME!

### Scenario 4: ConfigMap Change

**Problem:** ConfigMap changes don't restart pods automatically

**Solution:**
```bash
kubectl rollout restart deployment/resilient-spring-platform
```

**Alternative (automatic reload):**
- Reloader operator (Stakater Reloader)
- Spring Cloud Config Server
- Sidecar with fsnotify

---

## 🎓 Lessons Learned

### 1. **Multi-Stage Docker Build je Must-Have**
- **Benefit:** Image size 200MB umesto 800MB
- **Benefit:** Build cache ubrzava rebuild 10x
- **Trade-off:** Debugging je teži (nema dev tools u production image)

### 2. **Resource Limits = Stability**
- Without limits = one pod can crash entire node
- Requests enable K8s scheduler to properly distribute pods
- Limits prevent "noisy neighbor" problem

### 3. **Health Probes are Critical**
- Liveness = recovery automation
- Readiness = zero-downtime deployments
- Without probes = manual intervention required

### 4. **Configuration Externalization**
- Same image = dev/staging/prod (12-Factor App)
- Changes without rebuilding application
- Centralized configuration

### 5. **Replicas ≥ 2 for High Availability**
- Rolling updates without downtime
- Fault tolerance (one pod crashes, other takes over)
- Load distribution

### 6. **Security Mindset**
- Non-root user (defense in depth)
- Secrets ≠ ConfigMap (sensitive vs non-sensitive)
- Minimal base image (reduced attack surface)

---

## 📚 Next Steps (After Demo)

### Intermediate Level:
- [ ] Add Ingress Controller (NGINX/Traefik)
- [ ] Implement Horizontal Pod Autoscaler (HPA)
- [ ] Add Prometheus metrics endpoint
- [ ] Implement Spring Boot Actuator custom health indicators
- [ ] Add readiness gate for gradual traffic shifting

### Advanced Level:
- [ ] Multi-environment setup (dev/staging/prod)
- [ ] Helm charts for templating
- [ ] CI/CD pipeline (GitHub Actions / Jenkins)
- [ ] Service Mesh (Istio/Linkerd)
- [ ] Observability stack (Prometheus + Grafana + Jaeger)
- [ ] GitOps workflow (ArgoCD / Flux)

---

## 🔗 Useful Commands Cheat Sheet

### Docker
```bash
# Build
docker build -t resilient-spring-platform:1.0.0 .

# Run
docker run -d -p 8080:8080 --name app resilient-spring-platform:1.0.0

# Logs
docker logs -f app

# Stop/Remove
docker stop app && docker rm app
```

### Kubernetes
```bash
# Deploy
kubectl apply -f k8s/

# Status
kubectl get all
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Logs
kubectl logs -f <pod-name>
kubectl logs -f deployment/resilient-spring-platform

# Port Forward
kubectl port-forward svc/resilient-spring-platform 8080:80

# Rollout
kubectl rollout restart deployment/resilient-spring-platform
kubectl rollout status deployment/resilient-spring-platform
kubectl rollout undo deployment/resilient-spring-platform

# Delete
kubectl delete -f k8s/
```

---

## 👤 Author

**Miloš Merdović** - DevOps Upskilling Project  
**Role Focus:** Java Developer → DevOps Growth Path

---

## 📄 License

This project is for educational purposes as part of an individual development assignment.

---

**For detailed architectural analysis, see:** [ARCHITECTURE-AND-DESIGN.md](./ARCHITECTURE-AND-DESIGN.md)
