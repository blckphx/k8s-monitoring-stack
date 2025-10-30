# Kubernetes Monitoring Stack

Prometheus + Grafana + Alertmanager on Kubernetes via Helm. Includes sample dashboards, alert rules, quickstart scripts, and an uninstall path.

## Features
- kube-prometheus-stack deployment (Prometheus, Grafana, Alertmanager)
- Ready-to-use Grafana dashboards and Prometheus alert rules
- Kind-based local demo; works on any Kubernetes with Helm
- Simple Makefile and scripts for install/uninstall/port-forward

## Prerequisites
- Docker
- kubectl
- Helm 3.x
- kind (for local demo)

## Quickstart (local with kind)
```bash
# 1) Create a local cluster
kind create cluster --name monitor

# 2) Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 3) Install kube-prometheus-stack with overrides
helm install mon prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f helm/values/monitoring.values.yaml

# 4) Port-forward Grafana
kubectl -n monitoring port-forward svc/mon-grafana 3000:80
```

Grafana credentials (default):
- User: admin
- Password: `kubectl get secret -n monitoring mon-grafana -o jsonpath='{.data.admin-password}' | base64 -d`

Open: http://localhost:3000

## Dashboards and Alerts
- Place JSON dashboards in `dashboards/` and load them via Grafana UI or provisioning (optional).
- Add alerting rules in `alerts/` (PrometheusRule CRD). Example:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: mon-custom-rules
  namespace: monitoring
spec:
  groups:
    - name: demo.rules
      rules:
        - alert: HighPodRestartRate
          expr: increase(kube_pod_container_status_restarts_total[5m]) > 3
          for: 2m
          labels:
            severity: warning
          annotations:
            summary: "High restart rate detected"
            description: "Pod {{ $labels.pod }} restarted more than 3 times in 5m"
```

Apply:
```bash
kubectl apply -f alerts/
```

## Uninstall / Cleanup
```bash
helm uninstall mon -n monitoring
kubectl delete ns monitoring --wait
kind delete cluster --name monitor
```

## Repo Layout
```
helm/
  values/
    monitoring.values.yaml
dashboards/
alerts/
.github/
  workflows/
    ci.yml
Makefile
README.md
```

## Make targets
```bash
make install       # Install stack into cluster
make port-forward  # Port-forward Grafana 3000->80
make uninstall     # Remove stack
```

## Notes
- For production, configure Alertmanager receivers (email/webhook), persistent storage, and RBAC as needed.
- This repo is for demo/portfolio purposes—names/IDs are placeholders.


