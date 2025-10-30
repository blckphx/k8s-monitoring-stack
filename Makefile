CLUSTER ?= monitor
NS ?= monitoring
RELEASE ?= mon
VALUES ?= helm/values/monitoring.values.yaml

install:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install $(RELEASE) prometheus-community/kube-prometheus-stack -n $(NS) --create-namespace -f $(VALUES)

upgrade:
	helm upgrade $(RELEASE) prometheus-community/kube-prometheus-stack -n $(NS) -f $(VALUES)

uninstall:
	-helm uninstall $(RELEASE) -n $(NS)
	-kubectl delete ns $(NS) --wait

kind:
	kind create cluster --name $(CLUSTER)

delete-kind:
	kind delete cluster --name $(CLUSTER)

port-forward:
	kubectl -n $(NS) port-forward svc/$(RELEASE)-grafana 3000:80


