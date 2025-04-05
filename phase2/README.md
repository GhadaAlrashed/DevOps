# Phase2

## Kubernetes Cluster using AKS

Files On AKS Folder

```bash
terraform init
terraform plan
terraform apply
```

```bash
az aks get-credentials --resource-group Test0Group --name ghada-cluster
```

```bash
k config use-context ghada-cluster
# Switched to context "ghada-cluster".
k get node
```

```
NAME                                STATUS   ROLES    AGE     VERSION
aks-agentpool-35101906-vmss000000   Ready    <none>   2m30s   v1.29.2
aks-agentpool-35101906-vmss000001   Ready    <none>   2m23s   v1.29.2
aks-agentpool-35101906-vmss000002   Ready    <none>   2m28s   v1.29.2
```

## Deploying Retool

Files On Retool Folder


```bash
terraform init
terraform plan
terraform apply
```

### For oomkilld and I don't have memory on the node:

```bash
az aks scale --resource-group Test0Group --name ghada-cluster --node-count 8 --nodepool-name agentpool
```

## Deploy a demo API

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

```bash
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace default
```
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```