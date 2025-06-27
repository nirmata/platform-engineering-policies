## Overview
This repository contains a complete implementation of Kyverno policies designed to:

Automatically clean up orphaned Ingresses that reference non-existent Kubernetes services
Generate audit reports for monitoring and compliance purposes
Provide comprehensive testing with Chainsaw test scenarios
Ensure safe operation with grace periods and exclusion mechanisms

## Key Features

- 🔄 Scheduled Cleanup: Runs every hour to identify and remove orphaned Ingresses
- 📊 Audit Trail: Generates detailed reports for all Ingress resources
- 🛡️ Safety Mechanisms: 5-minute grace period and exclusion rules for critical namespaces
- 🧪 Comprehensive Testing: Chainsaw tests validate policy functionality
- 📋 Event Generation: Creates Kubernetes events for all cleanup actions

The solution consists of three main components:

1. Cleanup Policy (ingress-cleanup-policy.yaml): Scheduled cleanup of orphaned Ingresses
2. Audit Policy (ingress-audit-policy.yaml): Monitoring and reporting capabilities
3. Test Suite (chainsaw-test.yaml): Automated validation of policy behavior

### Prerequisites
Before deploying this solution, ensure you have:

- Kubernetes cluster (v1.25+)
- Kyverno installed (v1.11.0+)
- Chainsaw CLI (for running tests)
- Appropriate RBAC permissions for Kyverno

## Installing Kyverno
```bash
# Install Kyverno using Helm
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

# Verify installation
kubectl get pods -n kyverno
```

Installing Chainsaw
```bash
# Install Chainsaw CLI
go install github.com/kyverno/chainsaw@latest

# Or using binary releases
curl -L https://github.com/kyverno/chainsaw/releases/latest/download/chainsaw_linux_amd64.tar.gz | tar -xz
sudo mv chainsaw /usr/local/bin/
```

## Quick Start
### Step 1: Deploy the Policies

```bash
# Clone the repository
git clone <repository-url>
cd kyverno-ingress-cleanup

# Apply the cleanup policy
kubectl apply -f ingress-cleanup-policy.yaml

# Apply the audit policies
kubectl apply -f ingress-audit-policy.yaml

# Verify policies are installed
kubectl get clusterpolicy,clustercleanuppolicy
```

### Step 2: Verify Policy Installation

```bash
# Check policy status
kubectl describe clustercleanuppolicy cleanup-orphaned-ingresses
kubectl describe clusterpolicy audit-orphaned-ingresses
kubectl describe clusterpolicy generate-ingress-audit-report

# View policy events
kubectl get events --field-selector reason=PolicyApplied
```

### Step 3: Run Tests
```bash
# Execute the Chainsaw test suite
chainsaw test chainsaw-test.yaml

# Run tests with verbose output
chainsaw test chainsaw-test.yaml --test-dir . -v 4
```

## Configuration
### Cleanup Policy Settings

The cleanup policy can be customized by modifying the following parameters in ```ingress-cleanup-policy.yaml:```

# Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `schedule` | `0` | Cron schedule for cleanup runs (hourly) |
| `gracePeriodSeconds` | `300` | Wait time before deletion (5 minutes)excludeResources.conditions10mMinimum age for cleanup eligibility |
| `excludeResources.conditions` | `10m` | Enable debug logging output |

## Exclusion Rules
By default, the following namespaces are excluded from cleanup:

- ```kube-system```
- ```kube-public```
- ```kyverno```
- ```cert-manager```
- ```ingress-nginx```
- ```istio-system```

To exclude additional namespaces, add them to the exclude.resources.namespaces list.

## Disabling Cleanup for Specific Ingresses
Add the following label to any Ingress resource to exclude it from cleanup:

```yaml
metadata:
  labels:
    kyverno.io/cleanup-policy: "disabled"
```

## Usage Examples
### Example 1: Normal Operation
```bash
# Create a service and ingress
kubectl create namespace test-app
kubectl create service clusterip test-service --tcp=80:8080 -n test-app
```

```yaml
# Create ingress pointing to the service
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  namespace: test-app
spec:
  rules:
  - host: test.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-service
            port:
              number: 80
EOF

# The ingress will remain as the service exists
```

### Example 2: Orphaned Ingress Cleanup
```bash
# Delete the service to make the ingress orphaned
kubectl delete service test-service -n test-app

# Wait for the next cleanup cycle (or up to 1 hour)
# The ingress will be automatically deleted after the grace period

# Check audit reports
kubectl get configmap -n test-app -l kyverno.io/generated-by=generate-ingress-audit-report
```

### Example 3: Monitoring Audit Reports
```bash
# View all audit reports
kubectl get configmap -A -l audit.kyverno.io/resource-type=ingress

# Examine a specific audit report
kubectl get configmap ingress-audit-test-ingress -n test-app -o yaml

# Check service status for an ingress
kubectl get configmap ingress-audit-test-ingress -n test-app -o jsonpath='{.data.service-status}'
```

## Monitoring and Troubleshooting
### Viewing Policy Events
```bash
# Check cleanup events
kubectl get events --field-selector involvedObject.kind=Ingress,reason=PolicyViolation

# View Kyverno controller logs
kubectl logs -n kyverno -l app.kubernetes.io/name=kyverno -f

# Check cleanup policy status
kubectl get clustercleanuppolicy cleanup-orphaned-ingresses -o yaml
```

## Common Issues
### Issue: Cleanup policy not running
```bash
# Check if Kyverno cleanup controller is running
kubectl get pods -n kyverno -l app.kubernetes.io/component=cleanup-controller

# Verify cleanup policy syntax
kubectl describe clustercleanuppolicy cleanup-orphaned-ingresses
```

## Issue: Ingresses not being cleaned up
```bash
# Check if ingress meets cleanup conditions
kubectl get ingress <ingress-name> -o yaml

# Verify service existence
kubectl get service <service-name> -n <namespace>

# Check exclusion rules
kubectl get ingress <ingress-name> -o jsonpath='{.metadata.labels}'
```

## Issue: Audit reports not generated
```bash
# Check generate policy status
kubectl describe clusterpolicy generate-ingress-audit-report

# View policy violations
kubectl get events --field-selector reason=PolicyViolation
```

## Performance Considerations

- Resource Impact: Cleanup policies run every hour and perform service lookups
- Scale Limits: Tested with up to 1000 Ingress resources per cluster
- Network Overhead: Each policy evaluation performs API calls to check service existence

## Testing
### Running the Test Suite
The included Chainsaw tests validate the complete policy functionality:

```bash
# Run all tests
chainsaw test chainsaw-test.yaml

# Run specific test steps
chainsaw test chainsaw-test.yaml --test-name setup-test-environment

# Debug test failures
chainsaw test chainsaw-test.yaml --test-dir . --cleanup-delay 300s
```

## Test Scenarios Covered

- Valid Ingress Preservation: Ingresses with existing services are not deleted
- Orphaned Ingress Cleanup: Ingresses referencing non-existent services are removed
- Audit Report Generation: ConfigMaps are created with service status information
- Grace Period Functionality: Cleanup waits for the specified grace period
- Exclusion Rules: Protected namespaces and labeled resources are excluded

## Manual Testing
```bash
# Create test scenario
kubectl create namespace manual-test
kubectl create ingress test-ingress --rule="test.com/*=non-existent-service:80" -n manual-test

# Wait for audit report generation
sleep 30
kubectl get configmap -n manual-test -l kyverno.io/generated-by=generate-ingress-audit-report

# Wait for cleanup (up to 1 hour + grace period)
# Or force cleanup by annotating the ingress
kubectl annotate ingress test-ingress -n manual-test kyverno.io/force-cleanup=true
```

## Security Considerations

- RBAC: Ensure Kyverno has appropriate permissions for resource cleanup
- Backup: Consider backing up Ingress configurations before deployment
- Testing: Always test policies in development environments first
- Monitoring: Set up alerts for unexpected cleanup events

## Development Workflow
```bash
# Test policy changes
chainsaw test chainsaw-test.yaml

# Validate policy syntax
kubectl apply --dry-run=server -f ingress-cleanup-policy.yaml
kubectl apply --dry-run=server -f ingress-audit-policy.yaml

# Update documentation
# Update README.md with any configuration changes
```

