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

✅ Unused ConfigMaps: Properly identified for cleanup
✅ Volume-mounted ConfigMaps: Preserved when used by pods
✅ Environment Variable ConfigMaps: Preserved when referenced in env
✅ EnvFrom ConfigMaps: Preserved when used in envFrom blocks
✅ Init Container ConfigMaps: Preserved when used by init containers
✅ Protected ConfigMaps: Respects cleanup.kyverno.io/exclude: "true" annotation
✅ System Namespaces: Excludes kube-system, kube-public, etc.
✅ Report Generation: Verifies audit and usage reports are created

# Usage Instructions

###1. Deploy the Policies

```
kubectl apply -f configmap-cleanup-policies.yaml
```


