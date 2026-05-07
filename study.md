# Shopflow-Lite Study Guide

This file explains the major concepts used in this project, what each one does, why it is used, and where it appears in the codebase.

## Quick Port Map

| Component | Internal Port | NodePort / Local Access | Job |
|---|---:|---:|---|
| Shopflow Flask app | `5000` | `http://$(minikube ip):30007` | Runs the e-commerce web app |
| Prometheus | `9090` | `http://$(minikube ip):30090` or `localhost:9090` with port-forward | Stores and queries metrics |
| Grafana | `3000` | `http://$(minikube ip):30300` or `localhost:3000` with port-forward | Shows dashboards |
| Jenkins | `8080` | `http://localhost:8080` | Runs CI/CD pipeline |

Prometheus is on port `9090` inside Kubernetes, exposed as NodePort `30090`.

## Project In One Line

Shopflow-Lite is a Flask e-commerce app packaged with Docker, deployed to Kubernetes on Minikube, automated with Jenkins, monitored with Prometheus, and visualized with Grafana.

## Application Layer

### Flask

Its job in this project:
Flask runs the Shopflow web application.

What it does:
It handles browser requests, renders HTML pages, manages cart routes, checkout routes, health checks, and the `/metrics` endpoint.

Why we chose it:
Flask is simple, lightweight, and easy to containerize. It is good for a small demo app where the focus is DevOps workflow rather than backend complexity.

Where it is used:
`app/app.py`

Important routes:
- `/` shows the home page.
- `/products` loads products from Supabase.
- `/cart` shows cart contents.
- `/checkout` places an order in session history.
- `/orders` shows order history.
- `/health` confirms the app is running.
- `/metrics` exposes Prometheus metrics.

### HTML Templates

Its job in this project:
Templates create the user interface for the e-commerce app.

What it does:
Flask renders templates and fills them with data such as products, cart items, totals, and orders.

Why we chose it:
Jinja templates are built into Flask workflows and keep the app simple without needing a separate frontend framework.

Where it is used:
`app/templates/`

Key files:
- `base.html` is the shared layout.
- `index.html` is the home page.
- `products.html` lists products.
- `cart.html` shows the cart.
- `checkout.html` confirms checkout.
- `orders.html` shows order history.

### Static Assets

Its job in this project:
Static assets provide styling and product images.

What it does:
CSS controls the look of the app, and images display products.

Why we chose it:
Static files are simple to serve from Flask and easy to include inside the Docker image.

Where it is used:
- `app/static/css/shopflow.css`
- `app/static/images/`

### Supabase

Its job in this project:
Supabase acts as the external database backend.

What it does:
The Flask app uses the Supabase Python client to fetch product data from a hosted PostgreSQL database.

Why we chose it:
Supabase avoids running a database inside Minikube for this demo. It gives a ready hosted database while keeping the Kubernetes setup focused on app deployment and monitoring.

Where it is used:
`app/app.py`

Related environment variables:
- `SUPABASE_URL`
- `SUPABASE_KEY`

### Environment Variables

Its job in this project:
Environment variables provide runtime configuration without hardcoding sensitive values in app code.

What it does:
The Flask app reads Supabase credentials from environment variables.

Why we chose it:
This is the standard way to pass configuration into containers and Kubernetes Pods.

Where it is used:
- `app/app.py`
- `k8s/deployment.yaml`
- `k8s/secret.yaml`

### Kubernetes Secret

Its job in this project:
The Secret stores Supabase credentials for the app.

What it does:
Kubernetes injects `SUPABASE_URL` and `SUPABASE_KEY` into the Shopflow container as environment variables.

Why we chose it:
Secrets are the Kubernetes-native way to store sensitive configuration separately from application code.

Where it is used:
`k8s/secret.yaml`

### Flask Session

Its job in this project:
Sessions store cart and order history data for a user.

What it does:
The app stores cart items and recent orders in the Flask session.

Why we chose it:
It keeps the demo simple. We do not need a separate cart table or Redis session store for this project.

Where it is used:
`app/app.py`

## Containerization Layer

### Docker

Its job in this project:
Docker packages the Flask app and its dependencies into a runnable image.

What it does:
It creates a consistent environment with Python, Flask, Supabase client, Prometheus client, templates, CSS, and images.

Why we chose it:
Docker makes the app portable. The same image can run locally, in Minikube, or through Jenkins deployment.

Where it is used:
- `Dockerfile`
- `setup.sh`
- `startup.sh`

### Dockerfile

Its job in this project:
The Dockerfile defines how to build the Shopflow image.

What it does:
It starts from `python:3.9-slim`, installs Python dependencies, copies the app, exposes port `5000`, and runs `python app.py`.

Why we chose it:
It is small, clear, and optimized enough for a demo app. Requirements are copied first so dependency installation can use Docker layer caching.

Where it is used:
`Dockerfile`

### Docker Image

Its job in this project:
The image is the deployable package for Shopflow.

What it does:
The project builds the image as `shopflow:latest` and `shopflow:metrics`.

Why we chose it:
Kubernetes runs containers from images, so the Flask app must be built into an image first.

Where it is used:
- `setup.sh`
- `startup.sh`
- `k8s/deployment.yaml`

### Docker Container

Its job in this project:
A container is the running instance of an image.

What it does:
Kubernetes runs Shopflow containers inside Pods. Jenkins also runs as a Docker container named `shopflow-jenkins`.

Why we chose it:
Containers isolate services and make them repeatable.

Where it is used:
- Shopflow runs in Kubernetes Pods.
- Jenkins runs through Docker on the host.

## Kubernetes Layer

### Kubernetes

Its job in this project:
Kubernetes runs, restarts, exposes, and manages the Shopflow app and monitoring stack.

What it does:
It creates Pods, Deployments, Services, Secrets, ServiceAccounts, RBAC rules, and monitoring workloads.

Why we chose it:
Kubernetes is the industry standard for container orchestration. This project demonstrates a realistic DevOps workflow.

Where it is used:
`k8s/`

### Minikube

Its job in this project:
Minikube provides a local Kubernetes cluster.

What it does:
It runs Kubernetes on your machine and exposes NodePort services through the Minikube IP.

Why we chose it:
It gives a realistic Kubernetes environment without needing cloud infrastructure.

Where it is used:
- `setup.sh`
- `startup.sh`
- local commands such as `minikube service shopflow-service --url`

### kubectl

Its job in this project:
`kubectl` is the command-line tool used to talk to Kubernetes.

What it does:
It applies YAML files, checks pods, watches rollouts, reads logs, and creates port-forwards.

Why we chose it:
It is the standard Kubernetes administration tool.

Where it is used:
- `setup.sh`
- `startup.sh`
- `Jenkinsfile`

### Manifest YAML

Its job in this project:
Manifest files describe desired Kubernetes resources.

What it does:
The YAML files tell Kubernetes what to create and maintain.

Why we chose it:
Declarative YAML is the normal Kubernetes workflow. You describe the target state, and Kubernetes tries to keep the cluster in that state.

Where it is used:
`k8s/*.yaml`

### Namespace

Its job in this project:
Namespaces separate monitoring resources from the main app.

What it does:
The `monitoring` namespace contains Prometheus, Grafana, kube-state-metrics, and node-exporter.

Why we chose it:
It keeps monitoring resources organized and separate from the default namespace where Shopflow runs.

Where it is used:
`k8s/monitoring-namespace.yaml`

### Deployment

Its job in this project:
Deployments manage long-running app workloads.

What it does:
The Shopflow Deployment runs 2 replicas of the app. Prometheus, Grafana, and kube-state-metrics also run as Deployments.

Why we chose it:
Deployments support replica management, rolling updates, and automatic replacement of failed Pods.

Where it is used:
- `k8s/deployment.yaml`
- `k8s/prometheus-deployment.yaml`
- `k8s/grafana-deployment.yaml`
- `k8s/kube-state-metrics.yaml`

### Pod

Its job in this project:
Pods are the smallest running units in Kubernetes.

What it does:
Each Shopflow Pod contains one Shopflow container listening on port `5000`.

Why we chose it:
Kubernetes always runs containers inside Pods.

Where it is used:
Created automatically by Deployments.

### Replica

Its job in this project:
Replicas provide multiple running copies of Shopflow.

What it does:
`k8s/deployment.yaml` sets `replicas: 2`, so Kubernetes keeps two Shopflow Pods running.

Why we chose it:
Multiple replicas improve availability and demonstrate Kubernetes scaling.

Where it is used:
`k8s/deployment.yaml`

### Label

Its job in this project:
Labels identify Kubernetes resources.

What it does:
Shopflow Pods use `app: shopflow`. Services and monitoring queries use this label to find the correct Pods.

Why we chose it:
Labels are how Kubernetes groups and selects resources.

Where it is used:
- `k8s/deployment.yaml`
- `k8s/service.yaml`
- dashboard PromQL queries

### Selector

Its job in this project:
Selectors connect Services and Deployments to matching Pods.

What it does:
The Shopflow Service selects Pods with `app: shopflow`.

Why we chose it:
Selectors make Kubernetes networking dynamic. If Pods are replaced, the Service still routes traffic to the new matching Pods.

Where it is used:
`k8s/service.yaml`

### Service

Its job in this project:
Services expose Pods over a stable network address.

What it does:
`shopflow-service` exposes Shopflow Pods on port `80` and forwards traffic to container port `5000`.

Why we chose it:
Pods can be recreated with new IPs. A Service gives stable access to the app.

Where it is used:
`k8s/service.yaml`

### NodePort

Its job in this project:
NodePort exposes services outside the cluster through a fixed port on the Minikube node.

What it does:
Shopflow is exposed on NodePort `30007`, Prometheus on `30090`, and Grafana on `30300`.

Why we chose it:
NodePort is simple for local Minikube access.

Where it is used:
- `k8s/service.yaml`
- `k8s/prometheus-service.yaml`
- `k8s/grafana-service.yaml`

### imagePullPolicy: Never

Its job in this project:
It tells Kubernetes not to pull the Shopflow image from Docker Hub.

What it does:
Kubernetes uses the image already loaded into Minikube.

Why we chose it:
The image is built locally and loaded with `minikube image load shopflow:metrics`.

Where it is used:
`k8s/deployment.yaml`

### Annotation

Its job in this project:
Annotations add extra metadata to Pods for Prometheus scraping.

What it does:
Shopflow Pods include:
- `prometheus.io/scrape: "true"`
- `prometheus.io/path: "/metrics"`
- `prometheus.io/port: "5000"`

Why we chose it:
Prometheus discovers annotated Pods and scrapes their `/metrics` endpoint automatically.

Where it is used:
`k8s/deployment.yaml`

### RBAC

Its job in this project:
RBAC controls what monitoring tools can read from Kubernetes.

What it does:
Prometheus and kube-state-metrics get permissions to list and watch resources such as Pods, nodes, services, and deployments.

Why we chose it:
Kubernetes requires explicit permissions for cluster-level discovery and metrics collection.

Where it is used:
- `k8s/prometheus-rbac.yaml`
- `k8s/kube-state-metrics.yaml`
- `k8s/jenkins-rbac.yaml`

### ServiceAccount

Its job in this project:
ServiceAccounts give Kubernetes workloads an identity.

What it does:
Prometheus uses a ServiceAccount to authenticate to the Kubernetes API.

Why we chose it:
Prometheus needs permission to discover Kubernetes targets.

Where it is used:
`k8s/prometheus-rbac.yaml`

### ClusterRole and ClusterRoleBinding

Its job in this project:
They grant cluster-wide read permissions to monitoring tools.

What it does:
The ClusterRole defines allowed actions. The ClusterRoleBinding attaches those permissions to a ServiceAccount.

Why we chose it:
Prometheus and kube-state-metrics need to inspect resources across namespaces.

Where it is used:
- `k8s/prometheus-rbac.yaml`
- `k8s/kube-state-metrics.yaml`

## CI/CD Layer

### Jenkins

Its job in this project:
Jenkins automates deployment to Kubernetes.

What it does:
It runs the pipeline defined in `Jenkinsfile`, verifies Kubernetes access, and applies Kubernetes manifests.

Why we chose it:
Jenkins is a popular CI/CD tool and clearly demonstrates pipeline automation.

Where it is used:
- Docker container `shopflow-jenkins`
- `Jenkinsfile`
- `setup.sh`
- `startup.sh`

### Jenkinsfile

Its job in this project:
The Jenkinsfile defines the CI/CD pipeline.

What it does:
It downloads `kubectl`, verifies Kubernetes access, and deploys Shopflow using `kubectl apply`.

Why we chose it:
Pipeline-as-code keeps CI/CD steps version-controlled with the project.

Where it is used:
`Jenkinsfile`

### Pipeline Stage

Its job in this project:
Stages split the Jenkins pipeline into understandable steps.

What it does:
The pipeline has stages for setting up `kubectl`, verifying Kubernetes access, and deploying.

Why we chose it:
Stages make pipeline logs easier to read and troubleshoot.

Where it is used:
`Jenkinsfile`

### KUBECONFIG

Its job in this project:
KUBECONFIG tells Jenkins how to connect to Minikube.

What it does:
The setup script copies the host kubeconfig into the Jenkins container and adjusts Minikube paths.

Why we chose it:
Jenkins runs inside a container, so it needs its own copy of Kubernetes credentials.

Where it is used:
- `setup.sh`
- `Jenkinsfile`

## Monitoring Layer

### Monitoring

Its job in this project:
Monitoring shows whether the app and infrastructure are healthy.

What it does:
Prometheus collects metrics. Grafana displays them. Exporters expose extra Kubernetes and node metrics.

Why we chose it:
Monitoring is a core DevOps practice. It helps detect failures, performance issues, restarts, and capacity problems.

Where it is used:
- `k8s/prometheus-*`
- `k8s/grafana-*`
- `k8s/node-exporter.yaml`
- `k8s/kube-state-metrics.yaml`
- `k8s/grafana-dashboards/`

### Prometheus

Its job in this project:
Prometheus collects and stores metrics.

What it does:
It scrapes metrics from Shopflow, Kubernetes, cAdvisor, node-exporter, kube-state-metrics, and Jenkins if available.

Why we chose it:
Prometheus is the standard monitoring system for Kubernetes environments.

Where it is used:
- `k8s/prometheus-config.yaml`
- `k8s/prometheus-deployment.yaml`
- `k8s/prometheus-service.yaml`

Port:
- Internal: `9090`
- NodePort: `30090`
- Local port-forward: `localhost:9090`

### Prometheus Scrape

Its job in this project:
Scraping is how Prometheus collects metrics.

What it does:
Prometheus sends HTTP requests to `/metrics` endpoints every 15 seconds.

Why we chose it:
Prometheus uses pull-based metrics collection by design.

Where it is used:
`k8s/prometheus-config.yaml`

### Prometheus ConfigMap

Its job in this project:
The ConfigMap stores Prometheus configuration.

What it does:
It contains `prometheus.yml`, including scrape jobs for Kubernetes APIs, nodes, cAdvisor, node-exporter, kube-state-metrics, Jenkins, and annotated Pods.

Why we chose it:
ConfigMaps separate configuration from container images.

Where it is used:
`k8s/prometheus-config.yaml`

### PromQL

Its job in this project:
PromQL queries metrics for dashboards.

What it does:
Grafana panels use PromQL expressions such as request rate, response latency, pod CPU, pod memory, restarts, and node metrics.

Why we chose it:
PromQL is Prometheus' native query language.

Where it is used:
`k8s/grafana-dashboards/*.json`

Example:
```promql
sum(rate(http_requests_total[1m]))
```

### prometheus-client

Its job in this project:
The Python Prometheus client exposes application metrics from Flask.

What it does:
It creates counters and histograms for HTTP request count and request duration.

Why we chose it:
Prometheus needs metrics in a compatible format, and `prometheus-client` provides that for Python.

Where it is used:
- `app/requirements.txt`
- `app/app.py`

### Counter Metric

Its job in this project:
The counter tracks how many HTTP requests Shopflow has served.

What it does:
`HTTP_REQUESTS` increases for each request and includes labels for method, endpoint, and status.

Why we chose it:
Counters are the correct metric type for values that only increase.

Where it is used:
`app/app.py`

Metric exposed:
`http_requests_total`

### Histogram Metric

Its job in this project:
The histogram tracks request duration.

What it does:
`HTTP_REQUEST_DURATION` records how long requests take and groups them into buckets.

Why we chose it:
Histograms allow Grafana to calculate p50 and p95 latency.

Where it is used:
`app/app.py`

Metric exposed:
`http_request_duration_seconds_bucket`

### /metrics Endpoint

Its job in this project:
`/metrics` exposes app metrics for Prometheus.

What it does:
It returns Prometheus-formatted metrics from the Flask app.

Why we chose it:
Prometheus expects applications to expose metrics over HTTP.

Where it is used:
`app/app.py`

### /health Endpoint

Its job in this project:
`/health` provides a simple health check.

What it does:
It returns JSON showing the app is running.

Why we chose it:
Health endpoints are useful for testing, scripts, monitoring, and future readiness/liveness probes.

Where it is used:
`app/app.py`

### Grafana

Its job in this project:
Grafana visualizes metrics from Prometheus.

What it does:
It displays dashboards for Kubernetes, Shopflow application performance, deployment health, and infrastructure.

Why we chose it:
Grafana is the standard dashboard tool used with Prometheus.

Where it is used:
- `k8s/grafana-deployment.yaml`
- `k8s/grafana-service.yaml`
- `k8s/grafana-dashboards/`
- `k8s/create-dashboards.sh`

Port:
- Internal: `3000`
- NodePort: `30300`
- Local port-forward: `localhost:3000`

### Grafana Data Source

Its job in this project:
The data source connects Grafana to Prometheus.

What it does:
Grafana uses the Prometheus data source URL to run PromQL queries.

Why we chose it:
Grafana does not store Prometheus metrics itself. It needs a data source connection.

Where it is used:
`k8s/create-dashboards.sh`

Important detail:
The script detects the real Prometheus datasource UID every run. This prevents dashboards from breaking because of stale UIDs.

### Grafana Dashboard

Its job in this project:
Dashboards organize metrics into visual panels.

What it does:
They show CPU, memory, request rate, response time, restarts, replicas, node metrics, and deployment health.

Why we chose it:
Dashboards make raw metrics easy to understand.

Where it is used:
`k8s/grafana-dashboards/`

Dashboards:
- `kubernetes-cluster.json`
- `shopflow-app.json`
- `jenkins-ci-cd.json`
- `infrastructure.json`

### kube-state-metrics

Its job in this project:
kube-state-metrics exposes Kubernetes object state as Prometheus metrics.

What it does:
It provides metrics about Deployments, Pods, replicas, nodes, and other Kubernetes objects.

Why we chose it:
Prometheus alone does not automatically know Kubernetes object status. kube-state-metrics exposes that state.

Where it is used:
`k8s/kube-state-metrics.yaml`

Example metrics:
- `kube_deployment_status_replicas`
- `kube_pod_status_phase`
- `kube_node_info`

### node-exporter

Its job in this project:
node-exporter exposes machine-level metrics.

What it does:
It collects CPU, memory, filesystem, and disk metrics from the Minikube node.

Why we chose it:
Infrastructure dashboards need node-level metrics, not only app metrics.

Where it is used:
`k8s/node-exporter.yaml`

Example metrics:
- `node_cpu_seconds_total`
- `node_memory_MemAvailable_bytes`
- `node_filesystem_avail_bytes`

### cAdvisor

Its job in this project:
cAdvisor exposes container resource metrics through the kubelet.

What it does:
It provides container CPU, memory, and network metrics.

Why we chose it:
Container-level metrics are needed to monitor Pods and application resource usage.

Where it is used:
Configured in `k8s/prometheus-config.yaml` under the `kubernetes-cadvisor` scrape job.

Example metrics:
- `container_cpu_usage_seconds_total`
- `container_memory_usage_bytes`
- `container_network_transmit_bytes_total`

## Automation Scripts

### setup.sh

Its job in this project:
`setup.sh` performs first-time setup.

What it does:
It starts Docker, starts Minikube, builds the Docker image, loads it into Minikube, deploys Shopflow, sets up Jenkins, deploys monitoring, warms metrics, and provisions Grafana dashboards.

Why we chose it:
It reduces first-time setup to one command.

Where it is used:
`setup.sh`

Run:
```bash
bash setup.sh
```

### startup.sh

Its job in this project:
`startup.sh` starts or refreshes the project after the first setup.

What it does:
It starts Docker, starts Minikube, refreshes Shopflow and monitoring manifests, waits for workloads, warms metrics, and re-imports Grafana dashboards.

Why we chose it:
It makes the daily rerun workflow repeatable.

Where it is used:
`startup.sh`

Run:
```bash
bash startup.sh
```

### create-dashboards.sh

Its job in this project:
It provisions Grafana datasource and dashboards.

What it does:
It waits for Grafana, creates or updates the Prometheus data source, verifies Grafana can query Prometheus, detects the current datasource UID, and imports dashboards.

Why we chose it:
Manual dashboard imports are error-prone. This script makes dashboards reproducible every run.

Where it is used:
`k8s/create-dashboards.sh`

### warm-dashboard-metrics.sh

Its job in this project:
It makes sure Grafana has metrics to display immediately after startup.

What it does:
It sends requests to Shopflow pages and waits until Prometheus sees `http_requests_total`.

Why we chose it:
Fresh dashboards can look empty until traffic exists and Prometheus scrapes the app. This script creates initial data.

Where it is used:
`k8s/warm-dashboard-metrics.sh`

## Networking Concepts

### Port

Its job in this project:
Ports identify where services listen.

What it does:
Shopflow listens on `5000`, Prometheus on `9090`, Grafana on `3000`, and Jenkins on `8080`.

Why we chose it:
These are standard ports for these tools or simple local defaults.

### targetPort

Its job in this project:
`targetPort` points to the container port receiving traffic.

What it does:
Shopflow Service receives traffic on port `80` and forwards it to container port `5000`.

Why we chose it:
It lets users access a clean service port while the app runs on Flask's port.

Where it is used:
`k8s/service.yaml`

### port-forward

Its job in this project:
Port-forwarding maps a Kubernetes service to localhost.

What it does:
It lets you open Grafana or Prometheus through `localhost`.

Why we chose it:
It is useful for local debugging and API checks.

Examples:
```bash
kubectl port-forward -n monitoring svc/prometheus-service 9090:9090
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
```

## Version Control

### Git

Its job in this project:
Git tracks source code and infrastructure changes.

What it does:
It stores changes to Flask code, Dockerfile, Kubernetes manifests, Jenkinsfile, scripts, and documentation.

Why we chose it:
Version control is required for reliable collaboration and CI/CD.

Where it is used:
Entire repository.

### Commit

Its job in this project:
Commits save known-good states.

What it does:
After dashboard or deployment fixes, a commit records the exact working version.

Why we chose it:
It lets you roll back, compare changes, and trigger CI/CD flows.

## How Everything Works Together

1. You run `bash setup.sh` for the first setup or `bash startup.sh` after that.
2. Docker builds the Shopflow image.
3. Minikube runs the local Kubernetes cluster.
4. Kubernetes deploys two Shopflow Pods.
5. The Shopflow Service exposes the app on NodePort `30007`.
6. Jenkins can apply Kubernetes manifests through the pipeline.
7. Prometheus scrapes Shopflow `/metrics`, Kubernetes, cAdvisor, node-exporter, and kube-state-metrics.
8. Grafana connects to Prometheus as a data source.
9. Grafana dashboards show application, deployment, cluster, and infrastructure metrics.
10. The warm-up script generates traffic so dashboard panels show data after startup.

## Most Important Commands

Start project after first setup:
```bash
bash startup.sh
```

First-time setup:
```bash
bash setup.sh
```

Get app URL:
```bash
minikube service shopflow-service --url
```

Open Prometheus:
```bash
echo "http://$(minikube ip):30090"
```

Open Grafana:
```bash
echo "http://$(minikube ip):30300"
```

Check Pods:
```bash
kubectl get pods -A
```

Check Shopflow logs:
```bash
kubectl logs -f deployment/shopflow
```

Check Prometheus targets:
```bash
curl "http://$(minikube ip):30090/api/v1/targets?state=active"
```

Re-import dashboards:
```bash
bash k8s/create-dashboards.sh
```

Warm dashboard metrics:
```bash
bash k8s/warm-dashboard-metrics.sh
```

## What To Say In An Interview

Short explanation:
This project demonstrates a complete local DevOps workflow. A Flask e-commerce app is containerized with Docker, deployed to a local Kubernetes cluster using Minikube, automated with Jenkins, monitored with Prometheus, and visualized with Grafana. Kubernetes manages replicas and services, Prometheus scrapes application and cluster metrics, and Grafana dashboards show app performance, deployment health, cluster status, and infrastructure metrics.

Stronger explanation:
The application exposes Prometheus metrics using the Python `prometheus-client`. Kubernetes Pod annotations tell Prometheus to scrape the `/metrics` endpoint. kube-state-metrics provides Kubernetes object state, node-exporter provides node metrics, and cAdvisor provides container metrics. Grafana is automatically provisioned with the correct Prometheus datasource UID so dashboards continue working after restarts.

