# Shopflow-Lite

A modern e-commerce application built with Flask, containerized with Docker, and orchestrated with Kubernetes. This project demonstrates a complete DevOps workflow with CI/CD integration using Jenkins.

## 🚀 Quick Start

### One-Time Setup
```bash
bash setup.sh
```

### Every Time You Start
```bash
bash startup.sh
```

### Access the Application
- **Shopflow App**: Run `minikube service shopflow-service --url`
- **Jenkins CI/CD**: `http://localhost:8080`
- **Kubernetes Dashboard**: `minikube dashboard`

## 📋 Project Structure

```
Shopflow-Lite/
├── app/                      # Flask application
│   ├── app.py               # Main Flask app
│   ├── requirements.txt      # Python dependencies
│   ├── templates/           # HTML templates
│   └── static/              # CSS, images, JS
├── k8s/                      # Kubernetes manifests
│   ├── deployment.yaml      # Pod deployment config
│   ├── service.yaml         # Service config
│   ├── secret.yaml          # Credentials
│   └── jenkins-rbac.yaml    # RBAC config
├── Dockerfile               # Container image
├── Jenkinsfile             # CI/CD pipeline
├── setup.sh                # First-time setup
├── startup.sh              # Quick startup
└── GUIDE.md                # Detailed guide
```

## 🛠️ Tech Stack

- **Backend**: Python Flask
- **Database**: Supabase (PostgreSQL)
- **Containerization**: Docker
- **Orchestration**: Kubernetes (Minikube)
- **CI/CD**: Jenkins
- **Infrastructure**: DevOps automation

## 📦 Prerequisites

- Docker
- Minikube
- kubectl
- Jenkins (installed via Docker)
- Git

## 🔄 How It Works

1. **Push Code**: `git push origin main`
2. **Jenkins Detects**: SCM change trigger activates
3. **Build & Deploy**: Jenkins downloads kubectl and deploys to Kubernetes
4. **Auto-Scale**: Kubernetes manages 2+ replicas of the app
5. **Live Access**: Application immediately available

## 📊 Monitoring

### View Logs
```bash
kubectl logs -f deployment/shopflow
```

### Check Pod Status
```bash
kubectl get pods
```

### Scale Replicas
```bash
kubectl scale deployment shopflow --replicas=3
```

### Watch Deployments
```bash
kubectl get pods -w
```

## 🔐 Environment Variables

The app uses Supabase for the database. Credentials are stored in Kubernetes secrets:
- `SUPABASE_URL`: Database URL
- `SUPABASE_KEY`: API key

## 📚 Documentation

- **Comprehensive Guide**: See [GUIDE.md](./GUIDE.md)
- **Setup Details**: See [setup.sh](./setup.sh)
- **Startup Script**: See [startup.sh](./startup.sh)

## 🐛 Troubleshooting

### Jenkins Can't Deploy
```bash
# Check kubeconfig
docker exec shopflow-jenkins cat /var/jenkins_home/.kube/config | grep server

# Verify Minikube accessibility
docker exec shopflow-jenkins kubectl get nodes
```

### Pods Not Running
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Docker Image Issues
```bash
# Rebuild and reload
docker build -t shopflow:latest .
minikube image load shopflow:latest
kubectl rollout restart deployment/shopflow
```

## 🎯 Features

✅ Automated deployment pipeline  
✅ Multi-replica Kubernetes deployment  
✅ Integrated CI/CD with Jenkins  
✅ Secure credential management  
✅ Easy local development with Minikube  
✅ Production-ready Docker image  
✅ Auto-scaling capabilities  
✅ Comprehensive monitoring and logging  

## 📝 License

MIT

## 👨‍💻 Author

Prem Choithani

---

**Last Updated**: May 6, 2026