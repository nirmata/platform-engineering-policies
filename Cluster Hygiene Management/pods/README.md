# Kyverno cleanup policy for Pods 
This folder includes Kyverno policies designed to cleanup bare pods which don't have ownerreference. This works in a 2 step process. The `mark-bare-pods-cleanup` policy mutates all the pods that don't have ownerreference with an annotation `allow-delete`: `"true"`. The `clean-bare-pods` is a cleanup policy that cleans up all the pods that have `allow-delete`: `"true"` annotation. 

## Prerequisites:
- A Kubernetes cluster with Kyverno 1.10 or above installed. 

## Usage:

### RBAC Configuration
For the Kyverno policies to mutate and cleanup correctly, Kyverno requires permissions to mutate and cleanup the pods across all namespaces. Deploy the necessary rbac YAML's (`cleanup-clusterrole.yaml`,`cleanup-clusterrolebinding.yaml`,`mutatepod-clusterrole.yaml` and `mutatepod-clusterrolebinding.yaml`) before deploying the mutation and cleanup policies.

```
kubectl apply -f cleanup-clusterrole.yaml -f cleanup-clusterrolebinding.yaml -f mutatepod-clusterrole.yaml -f mutatepod-clusterrolebinding.yaml
```

### Deploying the Kyverno Policies
The first step is to deploy the mutation policy. This will mark all the pods for cleanup. Please note that this policy only applies `kyverno-test` namespace

```
kubectl apply -f mark-bare-pods-cleanup.yaml
```
Review the pods that have the `allow-delete`: `"true"` cleanup annotation. Deploy the cleanup policy that will cleanup all pods without ownerreference. 

```
kubectl apply -f cleanup-bare-pods.yaml
```

