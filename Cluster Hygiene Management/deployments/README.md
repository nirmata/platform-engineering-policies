## Cleanup stale deployments

This folder consists of Kyverno policies to identity deployments that have been scaled to 0 and never brought up in the last 30 days and then delete those deployments using the cleanup policy. The `mark-unused-deployments` policy finds all the deployments that are scaled to 0 for more than 30 days and then adds an annotation `allow-delete: "true"` to them. The `clean-stale-deployments` policy deletes all the deployments that have the allow-delete: "true"` annotation. 

NOTE: Necessary RBAC permissions to update and delete the deployments must be provided prior to deploying the policy. 