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

**SENIORSKI TIP:** Multi-stage build optimizacija

```bash
docker build -t resilient-spring-platform:1.0.0 .
```

**Pitanje:** Koliko vremena traje prvi build vs drugi build?
**Odgovor:** Prvi build = ~3-5 min (skida dependencies), Drugi build = ~30s (cache!)

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

**Pitanje:** Koliko je veliki final image?
```bash
docker images resilient-spring-platform:1.0.0

# Expected: ~200-250MB (JRE + Alpine + JAR)
# Bez multi-stage: ~800MB+ (JDK + Maven + cache)
```

---

## ☸️ Kubernetes Deployment

### Prerequisites: Docker Desktop Kubernetes

1. **Enable Kubernetes** u Docker Desktop settings
2. **Verify context:**
   ```bash
   kubectl config current-context
   # Should show: docker-desktop
   ```

### Deploy to Kubernetes

#### Step 1: Load Docker Image u Kubernetes
```bash
# Docker Desktop automatski vidi lokalne image-e
# Provera:
docker images | grep resilient-spring-platform
```

#### Step 2: Apply Kubernetes Manifests
```bash
# Apply sve manifeste odjednom
kubectl apply -f k8s/

# Ili jedan po jedan (za učenje):
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

**Prioritet (najviši ka najnižem):**
1. **Kubernetes Secret/ConfigMap** (Production)
2. **Environment Variables** (Docker/OS)
3. **application.properties** (Default values)

### Example: Promena poruke

#### Option 1: Edit ConfigMap
```bash
kubectl edit configmap app-config

# Change: APP_GREETING_MESSAGE: "Zdravo iz K8s"

# Restart pods za reload
kubectl rollout restart deployment/resilient-spring-platform
```

#### Option 2: Apply novi ConfigMap
```yaml
# k8s/configmap.yaml
data:
  APP_GREETING_MESSAGE: "Izmenjeno!"
```
```bash
kubectl apply -f k8s/configmap.yaml
kubectl rollout restart deployment/resilient-spring-platform
```

**Pitanje:** Zašto mora restart?
**Odgovor:** Spring Boot ne prati ConfigMap promene automatski. Za dynamic reload treba Spring Cloud Config Server ili sidecar pattern.

---

## 🛡️ Production Readiness

### Resource Management

**CPU i Memory Limits su definisani u deployment.yaml:**

```yaml
resources:
  requests:
    cpu: 100m      # Garantovani minimum
    memory: 256Mi
  limits:
    cpu: 500m      # Maksimum
    memory: 512Mi
```

**Pitanje:** Šta ako app zatraži više od limit-a?
**Odgovor:**
- **CPU:** Throttling (usporenje, ne kill)
- **Memory:** OOMKilled (pod se restartuje)

### Health Probes

#### Liveness Probe
```bash
# Direktan test
curl http://localhost:8080/actuator/health/liveness

# Expected: {"status":"UP"}
```

**Šta radi:** Ako 3x fail → K8s restartuje pod

#### Readiness Probe
```bash
curl http://localhost:8080/actuator/health/readiness
```

**Šta radi:** Ako fail → Pod se uklanja iz Service load balancinga

### Security

✅ **Non-root user** (UID 1001)  
✅ **Read-only filesystem** (gde je moguće)  
✅ **Minimal base image** (Alpine Linux)  
✅ **No hardcoded secrets**  
✅ **Resource limits** (anti DoS)

---

## 💥 Failure Scenarios

### Scenario 1: Pod Crashes

**Simulacija:**
```bash
# Ubij pod
kubectl delete pod -l app=resilient-spring-platform --grace-period=0

# Posmatraj recovery
kubectl get pods -w
```

**Šta se dešava:**
1. Liveness probe fails
2. K8s kreira novi pod (replicas=2 config)
3. Service automatski rutira traffic na healthy pod
4. **Downtime:** ~0-5s (zbog replicas=2)

### Scenario 2: Memory Leak (OOMKill)

**Simulacija:**
```bash
# Smanji memory limit
kubectl set resources deployment/resilient-spring-platform \
  --limits=memory=128Mi

# Povećaj load
for i in {1..100}; do curl http://localhost:30080/api/greet?name=Test$i; done
```

**Šta se dešava:**
1. Memory usage raste
2. Prelazi 128Mi limit
3. OOMKilled
4. K8s restartuje pod
5. Check events: `kubectl describe pod <pod-name>`

### Scenario 3: Rolling Update

**Simulacija:**
```bash
# Promeni image tag
kubectl set image deployment/resilient-spring-platform \
  app=resilient-spring-platform:2.0.0

# Posmatraj rollout
kubectl rollout status deployment/resilient-spring-platform
```

**Šta se dešava:**
1. K8s kreira novi pod (v2.0.0)
2. Čeka readiness probe
3. Novi pod postaje healthy
4. K8s šalje traffic na novi pod
5. Stari pod se gasi (graceful shutdown)
6. **maxUnavailable=0** = ZERO DOWNTIME!

### Scenario 4: ConfigMap Change

**Problem:** Promena ConfigMap ne restartuje podove automatski

**Rešenje:**
```bash
kubectl rollout restart deployment/resilient-spring-platform
```

**Alternativa (automatski reload):**
- Reloader operator (Stakater Reloader)
- Spring Cloud Config Server
- Sidecar sa fsnotify

---

## 🎓 Lessons Learned

### 1. **Multi-Stage Docker Build je Must-Have**
- **Benefit:** Image size 200MB umesto 800MB
- **Benefit:** Build cache ubrzava rebuild 10x
- **Trade-off:** Debugging je teži (nema dev tools u production image)

### 2. **Resource Limits = Stabilnost**
- Bez limits = jedan pod može kolapširati ceo node
- Requests omogućavaju K8s scheduleru da pravilno rasporedi podove
- Limits sprečavaju "noisy neighbor" problem

### 3. **Health Probes su Kritične**
- Liveness = recovery automation
- Readiness = zero-downtime deployments
- Bez probes = manual intervention required

### 4. **Configuration Eksternalizacija**
- Isti image = dev/staging/prod (12-Factor App)
- Promene bez rebuild aplikacije
- Centralizovana konfiguracija

### 5. **Replicas ≥ 2 za High Availability**
- Rolling updates bez downtime
- Fault tolerance (jedan pod crashuje, drugi preuzima)
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

**Za detaljnu arhitekturnu analizu, pogledaj:** [ARCHITECTURE-AND-DESIGN.md](./ARCHITECTURE-AND-DESIGN.md)
