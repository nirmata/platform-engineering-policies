#!/bin/bash

set -e

echo "Starting ConfigMap Cleanup Policy Tests..."

# Check if Kyverno is installed
if ! kubectl get deployment kyverno-admission-controller -n kyverno >/dev/null 2>&1; then
    echo "Error: Kyverno is not installed. Please install Kyverno first."
    echo "Run: helm install kyverno kyverno/kyverno -n kyverno --create-namespace"
    exit 1
fi

# Check if Chainsaw is installed
if ! command -v chainsaw &> /dev/null; then
    echo "Error: Chainsaw is not installed. Please install Chainsaw first."
    echo "Visit: https://kyverno.github.io/chainsaw/latest/install/"
    exit 1
fi

# Check if Chainsaw is installed
if ! command -v chainsaw &> /dev/null; then
    echo "Error: Chainsaw is not installed. Please install Chainsaw first."
    echo "Visit: https://kyverno.github.io/chainsaw/latest/install/"
    exit 1
fi

# Create test directory structure
mkdir -p tests/configmap-cleanup/{policies,manifests}

# Copy policy files
cp configmap-cleanup-policies.yaml tests/configmap-cleanup/policies/

# Run the tests
echo "Running Chainsaw tests..."
chainsaw test tests/configmap-cleanup/

echo "Tests completed successfully!"

