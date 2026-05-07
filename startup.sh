#!/bin/bash

# Shopflow-Lite Startup Script
# Run this script every time to start the project

set -e  # Exit on error

echo "================================================"
echo "  Shopflow-Lite Startup Script"
echo "================================================"
echo ""

# Step 1: Verify prerequisites
echo "✓ Checking prerequisites..."
for cmd in docker minikube kubectl curl jq; do
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
if docker ps > /dev/null 2>&1; then
    echo "✅ Docker is running"
else
    echo "❌ Docker failed to start"
    exit 1
fi
echo ""

# Step 3: Start Minikube
echo "☸️  Starting Minikube cluster..."
if minikube status | grep -q "Running"; then
    echo "✅ Minikube is already running"
else
    minikube start --memory=4096 --cpus=2
    echo "✅ Minikube started"
fi
echo ""

# Step 4: Verify cluster is accessible
echo "🔍 Verifying Kubernetes cluster..."
if kubectl cluster-info > /dev/null 2>&1; then
    echo "✅ Kubernetes cluster is accessible"
else
    echo "❌ Kubernetes cluster is not accessible"
    exit 1
fi
echo ""

# Step 5: Refresh Shopflow deployment
echo "🚀 Refreshing Shopflow deployment..."
if docker image inspect shopflow:metrics > /dev/null 2>&1; then
    minikube image load shopflow:metrics
else
    echo "⚠️  Docker image shopflow:metrics not found"
    echo "   Run the setup script first: bash setup.sh"
    exit 1
fi
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
echo "✅ Shopflow manifests applied"
echo ""

# Step 6: Start Jenkins
echo "🔨 Starting Jenkins container..."
if docker ps | grep -q shopflow-jenkins; then
    echo "✅ Jenkins is already running"
else
    if docker ps -a | grep -q shopflow-jenkins; then
        docker start shopflow-jenkins
        echo "✅ Jenkins container started"
    else
        echo "⚠️  Jenkins container not found"
        echo "   Run the setup script first: bash setup.sh"
        exit 1
    fi
fi
sleep 5
echo ""

# Step 7: Refresh monitoring stack
echo "📊 Refreshing monitoring stack..."
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

# Step 8: Wait for pods to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl rollout status deployment/shopflow --timeout=120s
kubectl rollout status deployment/prometheus-server -n monitoring --timeout=120s
kubectl rollout status deployment/grafana -n monitoring --timeout=120s
kubectl rollout status deployment/kube-state-metrics -n monitoring --timeout=120s
kubectl rollout status daemonset/node-exporter -n monitoring --timeout=120s
echo "✅ Deployments are ready"
echo ""

# Step 9: Warm Prometheus metrics for Grafana panels
echo "🔥 Warming dashboard metrics..."
bash k8s/warm-dashboard-metrics.sh
echo ""

# Step 10: Provision Grafana
echo "📈 Provisioning Grafana data source and dashboards..."
bash k8s/create-dashboards.sh
echo ""

# Step 11: Verify all services
echo "================================================"
echo "  ✅ All Services Started Successfully!"
echo "================================================"
echo ""
echo "📋 Quick Access URLs:"
echo ""
echo "  🌐 Shopflow Application:"
echo "     $(minikube service shopflow-service --url)"
echo ""
echo "  🔨 Jenkins CI/CD:"
echo "     http://localhost:8080"
echo ""
echo "  📊 Prometheus Metrics:"
MINIKUBE_IP=$(minikube ip)
echo "     http://${MINIKUBE_IP}:30090"
echo ""
echo "  📈 Grafana Dashboard:"
echo "     http://${MINIKUBE_IP}:30300"
echo "     (Default: admin / admin123)"
echo ""
echo "  🎛️  Kubernetes Dashboard (optional):"
echo "     minikube dashboard"
echo ""
echo "================================================"
echo ""
echo "💡 Next Steps:"
echo "  1. Push code changes: git push origin main"
echo "  2. Jenkins will auto-detect and deploy"
echo "  3. Check pod status: kubectl get pods"
echo "  4. View metrics: http://${MINIKUBE_IP}:30090"
echo ""
echo "📚 For more info, see: GUIDE.md"
echo "================================================"
