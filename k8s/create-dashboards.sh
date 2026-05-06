#!/bin/bash

# Script to create Grafana dashboards from JSON files

GRAFANA_URL="http://grafana-service.monitoring.svc.cluster.local:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="admin123"

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
sleep 10

# Create data source
echo "Creating Prometheus data source..."
curl -s -X POST "$GRAFANA_URL/api/datasources" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus-service.monitoring.svc.cluster.local:9090",
    "access": "proxy",
    "isDefault": true
  }' || echo "Data source might already exist"

echo ""
echo "Creating dashboards..."

# Function to create dashboard
create_dashboard() {
    local dashboard_file=$1
    local dashboard_name=$2
    
    echo "Creating dashboard: $dashboard_name"
    
    # Read dashboard file and create it
    curl -s -X POST "$GRAFANA_URL/api/dashboards/db" \
      -H "Content-Type: application/json" \
      -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
      -d "{\"dashboard\": $(cat $dashboard_file), \"overwrite\": true}" > /dev/null
    
    echo "✓ $dashboard_name created"
}

# Create all dashboards
create_dashboard "/dashboards/kubernetes-cluster.json" "Kubernetes Cluster Overview"
create_dashboard "/dashboards/shopflow-app.json" "Shopflow Application Performance"
create_dashboard "/dashboards/jenkins-ci-cd.json" "Jenkins CI/CD Pipeline"
create_dashboard "/dashboards/infrastructure.json" "Infrastructure Monitoring"

echo ""
echo "✅ All dashboards created successfully!"
echo "Access Grafana at: http://localhost:3000"
echo "Username: admin"
echo "Password: admin123"
