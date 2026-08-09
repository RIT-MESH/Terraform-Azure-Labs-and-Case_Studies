# 32 — Azure Kubernetes Service via Terraform

Provision a small AKS cluster with a system node pool of 1 node. After `apply`, get
credentials and deploy a pod:

```bash
az aks get-credentials -g rg-aks -n aks-cluster
kubectl get nodes
```

> AKS clusters take ~5-10 minutes to create. Use a Standard_B2s node for the pool.
