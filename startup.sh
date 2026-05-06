#!/bin/bash

# Shopflow-Lite Startup Script
# Run this script every time to start the project

set -e  # Exit on error

echo "================================================"
echo "  Shopflow-Lite Startup Script"
echo "================================================"
echo ""

# Step 1: Start Docker
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

# Step 2: Start Minikube
echo "☸️  Starting Minikube cluster..."
if minikube status | grep -q "Running"; then
    echo "✅ Minikube is already running"
else
    minikube start --memory=4096 --cpus=2
    echo "✅ Minikube started"
fi
echo ""

# Step 3: Verify cluster is accessible
echo "🔍 Verifying Kubernetes cluster..."
if kubectl cluster-info > /dev/null 2>&1; then
    echo "✅ Kubernetes cluster is accessible"
else
    echo "❌ Kubernetes cluster is not accessible"
    exit 1
fi
echo ""

# Step 4: Start Jenkins
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

# Step 5: Verify all services
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
echo "  📊 Kubernetes Dashboard (optional):"
echo "     minikube dashboard"
echo ""
echo "================================================"
echo ""
echo "💡 Next Steps:"
echo "  1. Push code changes: git push origin main"
echo "  2. Jenkins will auto-detect and deploy"
echo "  3. Check pod status: kubectl get pods"
echo ""
echo "📚 For more info, see: GUIDE.md"
echo "================================================"
