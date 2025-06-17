# Main Components
### 1. Cleanup Policy (cleanup-unused-configmaps)

Operation: Identifies ConfigMaps not used by any pods
Checks: Volumes, environment variables, envFrom references, and init containers
Protection: Respects exclusion annotations and system namespaces
Mode: Initially set to audit mode for safety

### 2. Audit Policy (audit-unused-configmaps)

Purpose: Generates detailed reports for unused ConfigMaps
Output: Creates report ConfigMaps with usage analysis
Benefits: Provides visibility before cleanup actions

### 3. Usage Report Policy (generate-configmap-usage-report)

Purpose: Creates comprehensive usage reports for all ConfigMaps
Details: Shows which pods use each ConfigMap and how (volume, env, envFrom)
Status: Marks ConfigMaps as "used" or "unused"

# Chainsaw Test Suite
The test validates all scenarios:
Test Coverage

#### 1. Unused ConfigMaps: Properly identified for cleanup
#### 2. Volume-mounted ConfigMaps: Preserved when used by pods
#### 3. Environment Variable ConfigMaps: Preserved when referenced in env
#### 4. EnvFrom ConfigMaps: Preserved when used in envFrom blocks
#### 5. Init Container ConfigMaps: Preserved when used by init containers
#### 6. Protected ConfigMaps: Respects cleanup.kyverno.io/exclude: "true" annotation
#### 7. System Namespaces: Excludes kube-system, kube-public, etc.
#### 8. Report Generation: Verifies audit and usage reports are created

# Usage Instructions

### 1. Deploy the Policies

``` yaml
kubectl apply -f configmap-cleanup-policies.yaml
```

### 2. Run the tests

``` yaml
# Make script executable
chmod +x clean-configmap-script.sh

# Run the complete test suite
./clean-configmap-script.sh
```
### 2. Monitor Reports

``` yaml
# Check unused ConfigMap reports
kubectl get configmaps -A | grep "unused-configmap-report"

# Check usage reports
kubectl get configmaps -A | grep "configmap-usage"
```
# Safety Features

## Protection Mechanisms

### Protection Mechanisms

### 1. Exclusion Annotation: Add 
``` yaml
cleanup.kyverno.io/exclude: "true"  # to protect ConfigMaps
```

### 2. System Namespace Protection: Automatically excludes critical namespaces

### 3. Audit Mode: Policies start in audit mode for safe observation

### 4. Comprehensive Checking: Validates all usage patterns (volumes, env, envFrom, init containers)

# Enabling Cleanup Mode
To switch from audit to enforcement:

``` yaml
spec:
  validationFailureAction: enforce  # Change from 'audit' to 'enforce'
```
# Report Examples

### Unused ConfigMap Report

``` yaml
data:
  usage-report.yaml: |
    configmap:
      name: "my-unused-config"
      namespace: "default"
    status: unused
    reason: "No pods found using this ConfigMap"
    recommendation: "Consider removing if no longer needed"
```

### usage Report

``` yaml
data:
  usage-report.yaml: |
    configmap:
      name: "my-config"
      namespace: "default"
    usage:
      volumeUsers: ["pod1", "pod2"]
      envUsers: ["pod3"]
      envFromUsers: []
      totalUsers: 3
    status: used
```
