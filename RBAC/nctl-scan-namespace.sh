#!/bin/bash

# Fetch all namespaces
namespaces=$(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name} {end}')

# Display namespaces for the user to select
echo "Available namespaces:"
i=1
declare -A ns_map
for ns in $namespaces; do
    echo "$i) $ns"
    ns_map[$i]=$ns
    ((i++))
done

# Prompt user to select namespaces
read -p "Enter the numbers corresponding to the namespaces you want to scan (e.g., 1 3 5): " ns_choices

# Validate input
selected_ns=""
for choice in $ns_choices; do
    if [[ -z "${ns_map[$choice]}" ]]; then
        echo "Invalid selection: $choice"
        exit 1
    fi
    selected_ns+="${ns_map[$choice]} "
done

# Run the scan for selected namespaces
for ns in $selected_ns; do
    echo "Running scan for namespace: $ns"
    time nctl scan kubernetes -p /Users/dolissharma/Downloads/solutions/RBAC-policies/Critical/ --cluster -n $ns
    echo "----------------------------------"
done
