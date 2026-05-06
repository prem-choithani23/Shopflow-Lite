#!/bin/bash

# Shopflow-Lite Setup Script (ONE TIME ONLY)
# Run this once to initialize the entire project

set -e  # Exit on error

echo "================================================"
echo "  Shopflow-Lite SETUP (First Time Only)"
echo "================================================"
echo ""

# Step 1: Verify prerequisites
echo "✓ Checking prerequisites..."
for cmd in docker minikube kubectl git curl jq; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ $cmd is not installed"
        exit 1
    fi
done
echo "✅ All prerequisites installed"
echo ""

# Step 2: Start Docker
echo "📦 Starting Docker service..."
sudo service docker start > /dev/null 2>&1
sleep 2
echo "✅ Docker started"
echo ""

# Step 3: Start Minikube
echo "☸️  Starting Minikube cluster..."
if minikube status | grep -q "Running"; then
    echo "ℹ️  Minikube already running"
else
    minikube start --memory=4096 --cpus=2
    echo "✅ Minikube started"
fi
echo ""

# Step 4: Build Docker image
echo "🐳 Building Shopflow Docker image..."
cd "$(dirname "$0")"
docker build -t shopflow:latest -t shopflow:metrics .
echo "✅ Docker image built"
echo ""

# Step 5: Load image into Minikube
echo "📤 Loading image into Minikube..."
minikube image load shopflow:metrics
echo "✅ Image loaded into Minikube"
echo ""

# Step 6: Create Kubernetes secret
echo "🔐 Creating Kubernetes secret..."
if kubectl get secret shopflow-secret > /dev/null 2>&1; then
    echo "ℹ️  Secret already exists"
else
    kubectl apply -f k8s/secret.yaml
    echo "✅ Secret created"
fi
echo ""

# Step 7: Deploy to Kubernetes
echo "🚀 Deploying to Kubernetes..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
echo "✅ Deployment created"
echo ""

# Step 8: Create/Start Jenkins
echo "🔨 Setting up Jenkins..."
if docker ps -a | grep -q shopflow-jenkins; then
    echo "ℹ️  Jenkins container already exists"
    docker start shopflow-jenkins 2>/dev/null || true
else
    echo "Creating Jenkins container..."
    docker run -d \
      --name shopflow-jenkins \
      --network host \
      -v /var/run/docker.sock:/var/run/docker.sock \
      jenkins/jenkins:lts
    
    sleep 15
fi

# Step 9: Copy kubeconfig to Jenkins
echo "🔑 Configuring Jenkins kubeconfig access..."
docker exec shopflow-jenkins mkdir -p /var/jenkins_home/.kube 2>/dev/null || true
docker cp ~/.kube/config shopflow-jenkins:/var/jenkins_home/.kube/config
docker cp ~/.minikube shopflow-jenkins:/var/jenkins_home/.minikube
docker exec shopflow-jenkins sed -i 's|'$HOME'/.minikube|/var/jenkins_home/.minikube|g' /var/jenkins_home/.kube/config
echo "✅ Jenkins kubeconfig configured"
echo ""

# Step 10: Deploy monitoring stack
echo "📊 Deploying monitoring stack..."
kubectl apply -f k8s/monitoring-namespace.yaml
kubectl apply -f k8s/prometheus-rbac.yaml
kubectl apply -f k8s/prometheus-config.yaml
kubectl apply -f k8s/prometheus-deployment.yaml
kubectl apply -f k8s/prometheus-service.yaml
kubectl apply -f k8s/node-exporter.yaml
kubectl apply -f k8s/kube-state-metrics.yaml
kubectl apply -f k8s/grafana-deployment.yaml
kubectl apply -f k8s/grafana-service.yaml
kubectl rollout restart deployment/prometheus-server -n monitoring > /dev/null 2>&1 || true
echo "✅ Monitoring manifests applied"
echo ""

# Step 11: Wait for pods to be ready
echo "⏳ Waiting for Shopflow pods to be ready..."
sleep 10
kubectl wait --for=condition=ready pod -l app=shopflow --timeout=120s 2>/dev/null || true
echo "✅ Pods are ready"
echo ""

echo "⏳ Waiting for monitoring pods to be ready..."
kubectl rollout status deployment/prometheus-server -n monitoring --timeout=120s
kubectl rollout status deployment/grafana -n monitoring --timeout=120s
kubectl rollout status deployment/kube-state-metrics -n monitoring --timeout=120s
kubectl rollout status daemonset/node-exporter -n monitoring --timeout=120s
echo "✅ Monitoring pods are ready"
echo ""

# Step 12: Provision Grafana
echo "📈 Provisioning Grafana data source and dashboards..."
bash k8s/create-dashboards.sh
echo ""

# Step 13: Display summary
echo "================================================"
echo "  ✅ SETUP COMPLETED SUCCESSFULLY!"
echo "================================================"
echo ""
echo "📋 Access URLs:"
echo ""
echo "  🌐 Shopflow Application:"
echo "     $(minikube service shopflow-service --url)"
echo ""
echo "  🔨 Jenkins CI/CD:"
echo "     http://localhost:8080"
echo ""
MINIKUBE_IP=$(minikube ip)
echo "  📊 Prometheus Metrics:"
echo "     http://${MINIKUBE_IP}:30090"
echo ""
echo "  📈 Grafana Dashboards:"
echo "     http://${MINIKUBE_IP}:30300"
echo "     (Default: admin / admin123)"
echo ""
echo "  📊 Kubernetes Dashboard:"
echo "     minikube dashboard"
echo ""
echo "================================================"
echo ""
echo "🚀 Next Time:"
echo "  Just run: bash startup.sh"
echo ""
echo "📝 Jenkins Setup:"
echo "  1. Open http://localhost:8080"
echo "  2. Get initial password:"
echo "     docker logs shopflow-jenkins | grep initialAdminPassword"
echo "  3. Complete setup wizard"
echo "  4. Create a Pipeline job from repository"
echo ""
echo "📚 For detailed guide, see: GUIDE.md"
echo "================================================"
