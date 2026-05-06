# Grafana Dashboards

This directory contains pre-configured Grafana dashboards for monitoring Shopflow-Lite.

## 📊 Available Dashboards

### 1. **Kubernetes Cluster Overview** (`kubernetes-cluster.json`)

Monitors the health and performance of your Kubernetes cluster:

- Pod CPU usage
- Pod Memory usage
- Total pods count
- Total nodes count
- Pods with restarts
- Failed pods

**Access**: `http://localhost:3000` → Search "Kubernetes Cluster Overview"

---

### 2. **Shopflow Application Performance** (`shopflow-app.json`)

Tracks real-time application metrics:

- HTTP request rate (requests/sec)
- Response time (p95)
- Error rate (5xx errors)
- Total requests/sec
- Shopflow replicas
- Error rate percentage
- Average response time

**Access**: `http://localhost:3000` → Search "Shopflow Application Performance"

---

### 3. **Jenkins CI/CD Pipeline** (`jenkins-ci-cd.json`)

Monitors your CI/CD pipeline health:

- Build success/failure rate
- Pipeline execution time
- Successful deployments (24h)
- Failed deployments (24h)
- Build success rate
- Average build duration

**Access**: `http://localhost:3000` → Search "Jenkins CI/CD Pipeline"

---

### 4. **Infrastructure Monitoring** (`infrastructure.json`)

Deep dive into node and infrastructure metrics:

- Node CPU usage
- Node Memory usage
- Disk I/O performance
- Average CPU usage
- Average Memory usage
- Average Disk available space
- Total nodes

**Access**: `http://localhost:3000` → Search "Infrastructure Monitoring"

---

## 🚀 How to Import Dashboards

### Option 1: Automatic Import (Recommended)

Run the setup script:

```bash
bash setup.sh
```

This automatically creates all dashboards during initial setup.

### Option 2: Manual Import via API

```bash
# From the k8s directory
./create-dashboards.sh
```

### Option 3: Manual Import via UI

1. Access Grafana: `http://<minikube-ip>:30300`
2. Login: `admin` / `admin123`
3. Go to **Dashboards** → **Import**
4. Upload JSON file from this directory
5. Select Prometheus as data source
6. Click **Import**

---

## 📈 Key Metrics to Monitor

### Application Performance

- **Request Rate**: Requests per second (target: 10-1000 req/s)
- **Error Rate**: Percentage of 5xx errors (target: < 1%)
- **Response Time (p95)**: 95th percentile latency (target: < 500ms)

### Infrastructure

- **CPU Usage**: Per node and pod (target: < 80%)
- **Memory Usage**: Per node and pod (target: < 80%)
- **Disk I/O**: Read/write throughput (monitor for bottlenecks)

### CI/CD

- **Build Success Rate**: Percentage of successful builds (target: > 95%)
- **Build Duration**: Time to complete pipeline (target: < 10 min)
- **Deployment Frequency**: Builds per day

---

## 🔧 Customization

### Add a New Dashboard

1. Create a dashboard in Grafana UI
2. Click **Dashboard settings** → **JSON Model**
3. Copy the JSON
4. Save to `grafana-dashboards/your-dashboard.json`
5. Commit and push
6. Jenkins will auto-deploy

### Edit Existing Dashboard

1. Open dashboard in Grafana
2. Make changes
3. Click **Save dashboard**
4. Export to JSON
5. Update the JSON file in this directory

### Add Custom Queries

Most dashboards use Prometheus queries. Common examples:

```promql
# Request rate
rate(http_requests_total[1m])

# Error rate
rate(http_requests_total{status=~"5.."}[1m])

# CPU usage percentage
rate(node_cpu_seconds_total[5m]) * 100

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

---

## 🔐 Credentials

- **Username**: `admin`
- **Password**: `admin123`

⚠️ **Important**: Change the default password immediately after setup!

---

## 📱 Accessing from Remote

Forward Grafana port to access from another machine:

```bash
kubectl port-forward -n monitoring svc/grafana-service 3000:3000 --address 0.0.0.0
```

Then access: `http://<your-machine-ip>:3000`

---

## 🛠️ Troubleshooting

### Dashboards Not Showing Data

1. Verify Prometheus is running: `kubectl get pods -n monitoring`
2. Check Prometheus data source in Grafana
3. Verify application is exporting metrics
4. Check Prometheus scrape configs

### Dashboard Import Fails

1. Ensure JSON is valid: `python -m json.tool dashboard.json`
2. Check data source name matches
3. Verify dashboard UID is unique

### Metrics Not Available

1. Check Prometheus is scraping targets
2. Verify metric names in Prometheus
3. Check application is exporting metrics
4. Wait a few minutes for data collection

---

## 📚 Resources

- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Kubernetes Metrics](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)

---

**Last Updated**: May 6, 2026
