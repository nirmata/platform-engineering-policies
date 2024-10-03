# Kyverno-Policy-Based Cleanup policy for Pods 
This repository includes resources for testing a Kyverno policy designed to cleanup bare pods which don't have ownerreference. This works in a 2 step process. The `mark-bare-pods-cleanup` policy mutates all the pods that don't have ownerreference with an annotation `delete-resource`: `allow`. The `clean-bare-pods` is a cleanup policy that cleans up all the pods that have `delete-resource`: `allow` annotation. 

## Prerequisites:
- A Kubernetes cluster with Kyverno 1.10 or above installed. 

## Usage:

### RBAC Configuration
For the Kyverno policies to mutate and cleanup correctly, Kyverno requires permissions to mutate and cleanup the pods across all namespaces. Deploy the necessary rbac YAML's (`cleanup-clusterrole.yaml`,`cleanup-clusterrolebinding.yaml`,`mutatepod-clusterrole.yaml` and `mutatepod-clusterrolebinding.yaml`) before deploying the mutation and cleanup policies.

```
kubectl apply -f cleanup-clusterrole.yaml -f cleanup-clusterrolebinding.yaml -f mutatepod-clusterrole.yaml -f mutatepod-clusterrolebinding.yaml
```

### Deploying the Kyverno Policies
The first step is to deploy the mutation policy. This will mark all the pods for cleanup. 

```
kubectl apply -f mark-bare-pods-cleanup.yaml
```
Review the pods that have the `delete-resource`: `allow` cleanup annotation. Deploy the cleanup policy that will cleanup all pods without ownerreference. 

```
kubectl apply -f cleanup-bare-pods.yaml
```

