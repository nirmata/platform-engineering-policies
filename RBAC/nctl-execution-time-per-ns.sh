#!/bin/bash

# Get all namespaces
namespaces=$(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name} {end}')

# Loop through each namespace
for ns in $namespaces; do
    echo "Running scan for namespace: $ns"
    # Measure time for each namespace scan
    time nctl scan kubernetes -p /Users/dolissharma/Downloads/solutions/RBAC-policies/Critical/ --cluster -n $ns
    echo "----------------------------------"
done
