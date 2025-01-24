# Resources for marking and deleting replicaSets in the Kubernetes cluster.

ReplicaSets serve as an intermediate controller for various Pod controllers like Deployments. When a new version of a Deployment is initiated, it generates a new ReplicaSet with the specified number of replicas and scales down the current one to zero. Consequently, numerous empty ReplicaSets may accumulate in the cluster, leading to clutter and potential false positives in policy reports if enabled. This folder consists of Kyverno policies to identiy replicasets that have 0 replicas and are older than 60 minutes and then delete them accordingly. The `mark-empty-replicasets-cleanup` policy first identifies the replicasets and then adds an annotation on them. The `cleanup-empty-replicasets` policy deletes all the replicasets that have the cleanup annotation.

NOTE: Necessary RBAC permissions to update and delete the replicasets must be provided prior to deploying the policy.

