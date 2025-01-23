## Deleting unused network policies

This folder consists of Kyverno policies used for marking and cleanup of network policies that are no longer used. The `unused-network-policies-policy` policy checks if there are any pods with specific label and value based on the pod selection from network and if there are no pods with matching labels, adds an annotation to the network policy to indiciate that the network policy can be deleted by the cleanuup policy. 

The `clean-unused-netpols` is the actual cleanup policy that runs every minute to check for network policies which have an annotation `llow-delete: "true"`