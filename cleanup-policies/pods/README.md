# Kyverno-Policy-Based Cleanup policy for Pods 
This repository includes resources for testing a Kyverno policy designed to cleanup bare pods which don't have ownerreference. This works in a 2 step process. The `mark-bare-pods-cleanup` policy mutates all the pods that don't have ownerreference with an annotation `delete-resource`: `allow`. The `clean-bare-pods` is a cleanup policy that cleans up all the pods that have `delete-resource`: `allow` annotation. 

## Prerequisites:
- A Kubernetes cluster with Kyverno 1.10 or above installed. 

## Usage:

### RBAC Configuration
For the Kyverno policies to mutate and cleanup correctly, Kyverno requires permissions to mutate and cleanup pods across all namespaces. Deploy `cleanup-clusterrole.yaml` and create clusterrolebinding to kyverno-cleanup-controller serviceaccount in kyverno namespace with clusterrole which we have created for this purpose.

```
kubectl apply -f cleanup-clusterrole.yaml
```
```
kubectl create clusterrolebinding kyvernocleanup-rs --clusterrole=kyverno:cleanup-rs  --serviceaccount=kyverno:kyverno-cleanup-controller
```

### Deploying the Kyverno Policy
The policy can be customized to include appropriate details like the creation timestamp of replicasets and Schedule, By default it cleans the replicasets which is created 30days back and whose replicas is 0. 
```
kubectl apply -f cleanup-replicasets.yaml
```

