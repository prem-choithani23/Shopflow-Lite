# 📊 Grafana Dashboards Setup Complete!

## ✅ What Was Created

I've created **4 awesome Grafana dashboards** for your Shopflow-Lite project:

### 1. **Kubernetes Cluster Overview** 🎯

Monitors the health of your entire Kubernetes cluster:

- Pod CPU usage trends
- Pod Memory usage
- Total pods running
- Total nodes
- Pods with restart count
- Failed pods

**Key Metrics**: Cluster health, pod crashes, resource allocation

---

### 2. **Shopflow Application Performance** 🚀

Real-time application monitoring:

- HTTP Request rate (req/sec)
- Response time (p95 percentile)
- Error rate (5xx errors)
- Active Shopflow replicas
- Error rate percentage
- Average response time

**Key Metrics**: API performance, user experience, error tracking

---

### 3. **Jenkins CI/CD Pipeline** 🔄

CI/CD pipeline analytics:

- Build success/failure rate
- Pipeline execution time
- Successful deployments (last 24h)
- Failed deployments (last 24h)
- Build success percentage
- Average build duration

**Key Metrics**: Deployment reliability, build speed, pipeline health

---

### 4. **Infrastructure Monitoring** 💻

Node and system-level metrics:

- Node CPU usage
- Node Memory usage
- Disk I/O performance
- Average CPU across all nodes
- Average Memory usage
- Disk availability
- Total nodes

**Key Metrics**: System resources, bottlenecks, capacity planning

---

## 🚀 How to Access Dashboards

### Get Grafana URL

```bash
minikube service grafana-service -n monitoring --url
# or
echo "Grafana: http://$(minikube ip):30300"
```

### Login Credentials

- **Username**: `admin`
- **Password**: `admin123`

### Import Dashboards

**Option 1: Automatic (Manual in UI)**

1. Open Grafana: `http://$(minikube ip):30300`
2. Go to **Dashboards** → **Import**
3. Select **Upload JSON file**
4. Upload from `k8s/grafana-dashboards/`
5. Choose Prometheus data source
6. Click **Import**

**Option 2: Copy Dashboard JSON**

1. In Grafana, click **+** → **Dashboard**
2. Click **Dashboard settings** → **JSON Model**
3. Copy JSON from the corresponding file in `k8s/grafana-dashboards/`
4. Paste and save

**Option 3: Programmatic (Curl)**

```bash
# Create data source
curl -X POST "http://localhost:3000/api/datasources" \
  -H "Content-Type: application/json" \
  -u "admin:admin123" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus-service.monitoring:9090",
    "access": "proxy",
    "isDefault": true
  }'

# Import dashboard
curl -X POST "http://localhost:3000/api/dashboards/db" \
  -H "Content-Type: application/json" \
  -u "admin:admin123" \
  -d @dashboard.json
```

---

## 📁 Files Created

```
k8s/
├── grafana-dashboards/
│   ├── README.md                          # Detailed dashboard guide
│   ├── kubernetes-cluster.json            # Cluster monitoring
│   ├── shopflow-app.json                  # App performance
│   ├── jenkins-ci-cd.json                 # CI/CD metrics
│   └── infrastructure.json                # Infrastructure metrics
├── create-dashboards.sh                   # Automation script
├── grafana-dashboards-configmap.yaml      # ConfigMap template
├── grafana-deployment.yaml                # Grafana K8s deployment
├── grafana-service.yaml                   # Grafana service
├── prometheus-*.yaml                      # Prometheus manifests
└── monitoring-namespace.yaml              # Monitoring namespace
```

---

## 🔧 Next Steps

### 1. Configure Data Source (First Time)

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/grafana-service 3000:3000 &

# Access: http://localhost:3000
# Login: admin / admin123
# Go to: Configuration → Data Sources → Add Prometheus
# URL: http://prometheus-service.monitoring:9090
```

### 2. Import Dashboards

- Upload JSON files from `k8s/grafana-dashboards/`
- Select Prometheus data source
- Customize as needed

### 3. Set Up Alerts (Optional)

- Click dashboard panel → **Alert**
- Configure thresholds
- Set notification channels

### 4. Create Custom Dashboards

- Mix and match panels from existing dashboards
- Use Prometheus queries for custom metrics

---

## 📈 Recommended Alerts

### Critical

- ❌ Error rate > 5%
- ❌ Response time (p95) > 1000ms
- ❌ Pod restarts in 5min
- ❌ Node CPU > 90%
- ❌ Node Memory > 90%

### Warning

- ⚠️ Error rate > 1%
- ⚠️ Response time (p95) > 500ms
- ⚠️ Build success rate < 90%
- ⚠️ Node CPU > 70%

### Info

- ℹ️ New deployment started
- ℹ️ Pod replica count changed
- ℹ️ High request rate detected

---

## 🔐 Security

⚠️ **Important**: Change default credentials!

```bash
# Access Grafana settings
# Admin → Users → Change Password

# Or via API
curl -X PUT "http://localhost:3000/api/user/password" \
  -H "Content-Type: application/json" \
  -u "admin:admin123" \
  -d '{"oldPassword":"admin123","newPassword":"YourNewPassword"}'
```

---

## 📚 Dashboard Details

### Query Examples

**CPU Usage**

```promql
rate(node_cpu_seconds_total[5m]) * 100
```

**Memory Usage**

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**Request Rate**

```promql
rate(http_requests_total[1m])
```

**Error Rate**

```promql
rate(http_requests_total{status=~"5.."}[1m])
```

---

## 🆘 Troubleshooting

### Dashboards Show "No Data"

1. ✅ Check Prometheus is running: `kubectl get pods -n monitoring`
2. ✅ Verify data source URL is correct
3. ✅ Check metrics exist: `http://prometheus:9090`
4. ✅ Wait 5 minutes for data collection

### Can't Access Grafana

```bash
# Check service
kubectl get svc -n monitoring

# Check pod logs
kubectl logs -n monitoring deployment/grafana

# Port-forward
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
```

### Wrong Credentials

- Reset: Go to Grafana → Admin → Users
- Default: `admin` / `admin123`

---

## 📞 Support Resources

- Grafana Dashboard JSON Format: https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/
- Prometheus Query Guide: https://prometheus.io/docs/prometheus/latest/querying/
- Kubernetes Metrics: https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/

---

## 🎉 You're All Set!

Your monitoring stack is ready with **Prometheus**, **Grafana**, and **4 pre-configured dashboards**!

**Start monitoring**:

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/grafana-service 3000:3000 &

# Access
open http://localhost:3000
# or
echo "Open: http://$(minikube ip):30300"
```

**Happy monitoring! 📊📈**

---

**Created**: May 6, 2026  
**Author**: GitHub Copilot  
**Project**: Shopflow-Lite
