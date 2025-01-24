## Delete stale namespaces

This folder consists of Kyverno policies to identity namespaces which don't any pods, services and deployments and then delete them accordingly. Namespaces without any pods, services and deployments indicate they are stale and not being used. 

NOTE: Necessary RBAC permissions to update and delete the namespaces must be provided prior to deploying the policy.