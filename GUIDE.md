# Shopflow-Lite: Complete Setup Guide

A comprehensive guide to run the Shopflow e-commerce application with Docker, Jenkins, and Kubernetes.

## Prerequisites

Before starting, ensure you have the following installed:

- **Docker** - Container runtime
- **Minikube** - Local Kubernetes cluster
- **kubectl** - Kubernetes command-line tool
- **Jenkins** - CI/CD automation (Docker container recommended)
- **Git** - Version control

## Project Architecture

```
Docker Container (shopflow:latest)
        ↓
Minikube Kubernetes Cluster
        ↓
2 Shopflow Pods (replicas) + Service
        ↓
Jenkins (CI/CD Pipeline)
```

---

## 1. STARTUP SEQUENCE (Core Infrastructure)

### Step 1: Start Docker Service

```bash
sudo service docker start
```

Verify Docker is running:

```bash
docker --version
docker ps
```

### Step 2: Start Jenkins Container

```bash
docker start shopflow-jenkins
```

If the container doesn't exist, create it:

```bash
docker run -d \
  --name shopflow-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

Access Jenkins at: **http://localhost:8080**

### Step 3: Start Minikube Kubernetes Cluster

```bash
minikube start
```

Verify Minikube is running:

```bash
minikube status
kubectl cluster-info
```

---

## 2. BUILD & DEPLOY APPLICATION

### Step 1: Build Docker Image

```bash
cd /path/to/Shopflow-Lite
docker build -t shopflow:latest .
```

### Step 2: Load Image into Minikube

```bash
minikube image load shopflow:latest
```

Verify image is loaded:

```bash
minikube image ls | grep shopflow
```

### Step 3: Create Kubernetes Secret

The application requires Supabase credentials. Create the secret:

```bash
kubectl apply -f k8s/secret.yaml
```

Or manually:

```bash
kubectl create secret generic shopflow-secret \
  --from-literal=SUPABASE_URL=https://jkfymuwtwvsallcrniuh.supabase.co \
  --from-literal=SUPABASE_KEY=sb_publishable_SiySoStSiPvy5Vzd47KP6g_Tk3Gosb_
```

### Step 4: Deploy to Kubernetes

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Verify deployment:

```bash
kubectl get pods
kubectl get svc
```

Expected output:

```
NAME                        READY   STATUS    RESTARTS
shopflow-67f6556c7b-blhdf   1/1     Running   0
shopflow-67f6556c7b-mhhq5   1/1     Running   0

NAME               TYPE        CLUSTER-IP       PORT(S)
shopflow-service   NodePort    10.100.141.141   80:30007/TCP
```

---

## 3. ACCESS THE APPLICATION

### Get Application URL

```bash
minikube service shopflow-service --url
```

Example output: `http://192.168.49.2:30007`

Open this URL in your browser to access Shopflow.

---

## 4. MONITORING & ACCESS

### A. View Application Logs

```bash
# View logs from all pods
kubectl logs -f deployment/shopflow

# View logs from specific pod
kubectl logs -f <pod-name>
```

### B. Check Pod Details

```bash
kubectl describe pod <pod-name>
```

### C. Port-Forward (Optional - for testing)

Forward port 5000 to localhost:

```bash
kubectl port-forward svc/shopflow-service 5000:80
```

Then access: `http://localhost:5000`

### D. Monitor Grafana (If monitoring stack is deployed)

Get Grafana admin password:

```bash
kubectl get secret --namespace monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Port-forward Grafana:

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 --address 0.0.0.0
```

Access: **http://localhost:3000**

---

## 5. SCALING & MANAGEMENT

### Scale Replicas

```bash
# Scale to 3 replicas
kubectl scale deployment shopflow --replicas=3

# Verify scaling
kubectl get pods
```

### Rolling Update

```bash
# Update image
kubectl set image deployment/shopflow shopflow=shopflow:v2.0 --record

# Check rollout status
kubectl rollout status deployment/shopflow
```

### Rollback

```bash
# View rollout history
kubectl rollout history deployment/shopflow

# Rollback to previous version
kubectl rollout undo deployment/shopflow
```

---

## 6. JENKINS INTEGRATION

### Access Jenkins

Open **http://localhost:8080** in your browser.

### Configure Jenkins

1. Complete the initial setup (unlock Jenkins with initial admin password)
2. Install recommended plugins
3. Create a new Pipeline job
4. Configure it to use the `Jenkinsfile` in the repository

### Trigger Pipeline

```bash
# The Jenkinsfile will:
# 1. Download kubectl
# 2. Apply Kubernetes manifests (deployment, service)
# 3. Deploy to Minikube cluster
```

---

## 7. TROUBLESHOOTING

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Image Pull Errors

```bash
# Verify image in Minikube
minikube image ls

# If not present, reload:
minikube image load shopflow:latest
```

### Connectivity Issues

```bash
# Check service endpoints
kubectl get endpoints shopflow-service

# Test connectivity from another pod
kubectl run -it --rm debug --image=busybox -- sh
# Inside pod: wget -O- http://shopflow-service
```

### Docker Issues

```bash
# Reset Docker daemon
docker system prune

# Check Docker logs
sudo journalctl -u docker
```

---

## 8. CLEANUP & SHUTDOWN

### Stop All Services (Keep Data)

```bash
# Stop Minikube
minikube stop

# Stop Jenkins
docker stop shopflow-jenkins
```

### Full Cleanup (Remove Everything)

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/service.yaml
kubectl delete secret shopflow-secret

# Stop and remove Minikube
minikube delete

# Stop Jenkins
docker stop shopflow-jenkins
docker rm shopflow-jenkins

# Remove Docker image
docker rmi shopflow:latest
```

---

## 9. QUICK REFERENCE

| Command                                          | Purpose                  |
| ------------------------------------------------ | ------------------------ |
| `docker build -t shopflow:latest .`              | Build Docker image       |
| `minikube image load shopflow:latest`            | Load image into Minikube |
| `kubectl apply -f k8s/*.yaml`                    | Deploy to Kubernetes     |
| `minikube service shopflow-service --url`        | Get application URL      |
| `kubectl get pods -w`                            | Watch pod status         |
| `kubectl logs -f deployment/shopflow`            | Stream logs              |
| `kubectl scale deployment shopflow --replicas=3` | Scale pods               |
| `minikube dashboard`                             | Open Minikube dashboard  |
| `docker ps`                                      | View running containers  |
| `kubectl describe pod <name>`                    | Get pod details          |

---

## 10. APPLICATION STRUCTURE

```
Shopflow-Lite/
├── app/                      # Flask application
│   ├── app.py               # Main application
│   ├── requirements.txt      # Python dependencies
│   ├── templates/           # HTML templates
│   └── static/              # CSS, images, JS
├── k8s/                      # Kubernetes manifests
│   ├── deployment.yaml      # Deployment configuration
│   ├── service.yaml         # Service configuration
│   ├── secret.yaml          # Secrets (credentials)
│   └── jenkins-rbac.yaml    # Jenkins RBAC
├── Dockerfile               # Docker image definition
├── Jenkinsfile             # CI/CD pipeline
└── GUIDE.md                # This file
```

---

## 11. ENVIRONMENT VARIABLES

The application uses these environment variables (configured via Kubernetes Secrets):

| Variable       | Description             |
| -------------- | ----------------------- |
| `SUPABASE_URL` | Supabase database URL   |
| `SUPABASE_KEY` | Supabase public API key |

---

## 12. PORTS OVERVIEW

| Service            | Port  | URL                   |
| ------------------ | ----- | --------------------- |
| Flask App          | 5000  | Internal (container)  |
| Kubernetes Service | 80    | Internal (cluster)    |
| NodePort           | 30007 | External (Minikube)   |
| Jenkins            | 8080  | http://localhost:8080 |
| Grafana            | 3000  | http://localhost:3000 |
| Prometheus         | 9090  | http://localhost:9090 |

---

## Support

For issues or questions, refer to:

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)

---

**Last Updated**: May 6, 2026
