#!/bin/bash

# Generate enough Shopflow traffic for Grafana request/latency panels to show data.

set -euo pipefail

APP_URL="${APP_URL:-}"
PROMETHEUS_QUERY_URL="${PROMETHEUS_QUERY_URL:-http://$(minikube ip):30090/api/v1/query}"
REQUEST_ROUNDS="${REQUEST_ROUNDS:-20}"
SCRAPE_TIMEOUT_SECONDS="${SCRAPE_TIMEOUT_SECONDS:-90}"

for cmd in curl kubectl minikube jq; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "❌ $cmd is required to warm dashboard metrics"
        exit 1
    fi
done

if [ -z "$APP_URL" ]; then
    APP_URL="$(minikube service shopflow-service --url)"
fi

echo "🔥 Warming Shopflow dashboard metrics at ${APP_URL}..."
for _ in $(seq 1 "$REQUEST_ROUNDS"); do
    curl -fsS "${APP_URL}/" > /dev/null || true
    curl -fsS "${APP_URL}/products" > /dev/null || true
    curl -fsS "${APP_URL}/health" > /dev/null || true
done
echo "✓ Traffic generated"

echo "⏳ Waiting for Prometheus to scrape Shopflow HTTP metrics..."
deadline=$((SECONDS + SCRAPE_TIMEOUT_SECONDS))
while [ "$SECONDS" -lt "$deadline" ]; do
    result_count="$(
        curl -fsS --get "$PROMETHEUS_QUERY_URL" \
          --data-urlencode 'query=sum(rate(http_requests_total[1m]))' \
        | jq '.data.result | length' 2>/dev/null || echo 0
    )"

    if [ "$result_count" -gt 0 ]; then
        echo "✓ Shopflow HTTP metrics are available in Prometheus"
        exit 0
    fi

    sleep 5
done

echo "⚠️  Shopflow HTTP metrics were not visible before timeout; dashboards will fill in after the next scrape"
