`***Before installation of helm-charts, make sure the terraform changes have been applied in terraform folder***`

Update the role arn's for aws load-balancer controller, cert-manager in values.yaml file.

# Helm installation command for aws load balancer controller:

```
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system -f helm/aws-lb-controller/values.yaml
```

# Helm installation for nginx-ingress:

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx ingress-nginx/ingress-nginx --namespace ingress -f helm/nginx/values.yaml --create-namespace
```

# Helm installation for cert-manager:

```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace -f helm/cert/values.yaml
```

# Helm installation for fluent-bit:

```
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
helm upgrade -i fluent fluent/fluent-bit --namespace fluent --create-namespace -f helm/fluent-bit/values.yaml
```

# Create basic auth for prometheus:

```
kubectl create secret generic prometheus-basic-auth --from-file=auth -n prometheus
```

# Helm installation for prometheus:

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade -i prom prometheus-community/prometheus --namespace prometheus --create-namespace -f helm/prometheus/values.yaml
```

# Helm installation for mimir:

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade -i mimir grafana/mimir-distributed -n mimir --create-namespace -f helm/mimir/values.yaml
```

# Helm installation for grafana:

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade -i graf grafana/grafana --namespace grafana --create-namespace -f helm/grafana/values.yaml
```

# Helm installation for argocd:

```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade -i argo argo/argo-cd --namespace argo --create-namespace -f helm/argocd/values.yaml
```

# Helm installation for opensearch-master:

```
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update
helm upgrade -i logs-master opensearch/opensearch --namespace opensearch --create-namespace -f helm/opensearch/master/values.yaml
```

# Helm installation for opensearch-data:

```
helm upgrade -i logs-data opensearch/opensearch --namespace opensearch --create-namespace -f helm/opensearch/data/values.yaml
```

# Helm installation for opensearch-dashboard:

```
helm upgrade -i logs-dashboard opensearch/opensearch-dashboards --namespace opendashboard --create-namespace -f helm/opensearch/dashboard/values.yaml
```

# Helm installation for metrics-server:

```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade -i metrics-server metrics-server/metrics-server -n metrics --create-namespace
```
# Helm installation for jenkins:

```
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade -i jenkins jenkins/jenkins -n jenkins --create-namespace -f helm/jenkins/values.yaml
```
