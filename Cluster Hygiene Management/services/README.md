# Delete unused services

This folder consists of Kyverno policies to identity services that may be unsed by checking the selector labels and verifing if pods with those labels exist on the cluster. If there are no pods with the selector labels, the service is considered as stale and marked for deletion. The `mark-unused-services-cleanup` policy adds an annotation to the services based on the pods and `clean-stale-services` policy deletes all the services that have `allow-delete: true` in them. 

NOTE: Necessary RBAC permissions to update and delete the services must be provided prior to deploying the policy.
