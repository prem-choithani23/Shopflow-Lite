#!/bin/bash

# Create/update Grafana data source and dashboards from local JSON files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DASHBOARD_DIR="${SCRIPT_DIR}/grafana-dashboards"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-admin123}"
GRAFANA_URL="${GRAFANA_URL:-http://$(minikube ip):30300}"
PROMETHEUS_URL="${PROMETHEUS_URL:-http://prometheus-service.monitoring.svc.cluster.local:9090}"

for cmd in curl jq; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "❌ $cmd is required to provision Grafana"
        exit 1
    fi
done

echo "⏳ Waiting for Grafana API at ${GRAFANA_URL}..."
for _ in {1..60}; do
    if curl -fsS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/health" > /dev/null 2>&1; then
        break
    fi
    sleep 2
done

if ! curl -fsS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/health" > /dev/null; then
    echo "❌ Grafana API is not ready at ${GRAFANA_URL}"
    exit 1
fi

echo "📡 Ensuring Prometheus data source exists..."
datasource_payload="{
    \"name\": \"Prometheus\",
    \"type\": \"prometheus\",
    \"url\": \"${PROMETHEUS_URL}\",
    \"access\": \"proxy\",
    \"isDefault\": true
  }"

existing_datasource="$(curl -fsS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/datasources/name/Prometheus" 2>/dev/null || true)"
if [ -n "$existing_datasource" ]; then
    datasource_uid="$(printf '%s' "$existing_datasource" | jq -r '.uid')"
    curl -fsS -X PUT "$GRAFANA_URL/api/datasources/uid/${datasource_uid}" \
      -H "Content-Type: application/json" \
      -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
      -d "$datasource_payload" > /dev/null
    echo "✓ Prometheus data source updated"
else
    curl -fsS -X POST "$GRAFANA_URL/api/datasources" \
      -H "Content-Type: application/json" \
      -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
      -d "$datasource_payload" > /dev/null
    echo "✓ Prometheus data source created"
fi

echo ""
echo "📊 Importing dashboards..."

create_dashboard() {
    local dashboard_file=$1
    local dashboard_name=$2

    jq -c '{dashboard: ., overwrite: true}' "$dashboard_file" > /tmp/grafana-dashboard-payload.json
    curl -fsS -X POST "$GRAFANA_URL/api/dashboards/db" \
      -H "Content-Type: application/json" \
      -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
      --data-binary @/tmp/grafana-dashboard-payload.json > /dev/null

    echo "✓ $dashboard_name"
}

create_dashboard "${DASHBOARD_DIR}/kubernetes-cluster.json" "Kubernetes Cluster Overview"
create_dashboard "${DASHBOARD_DIR}/shopflow-app.json" "Shopflow Application Performance"
create_dashboard "${DASHBOARD_DIR}/jenkins-ci-cd.json" "Jenkins CI/CD Pipeline"
create_dashboard "${DASHBOARD_DIR}/infrastructure.json" "Infrastructure Monitoring"

echo ""
echo "✅ Grafana dashboards are ready"
echo "Access Grafana at: ${GRAFANA_URL}"
echo "Username: admin"
echo "Password: admin123"
