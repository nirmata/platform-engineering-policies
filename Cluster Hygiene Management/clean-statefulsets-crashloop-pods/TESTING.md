# Testing StatefulSet Cleanup Policies

This guide provides instructions for testing the automated StatefulSet cleanup policies using the provided sample StatefulSet.

## 📁 Test Files

- `sample-crashloop-statefulset.yaml` - A StatefulSet that will consistently crash for testing

## 🧪 Testing Procedure

### Step 1: Deploy the Kyverno Policies

First, ensure Kyverno is installed in your cluster, then deploy all the StatefulSet cleanup policies:

```bash
# Deploy policies in order
kubectl apply -f 1-clusterpolicy-statefulset-crashloopback-mutation.yaml
kubectl apply -f 2-clusterpolicy-statefulset-crashloopback-validation.yaml
kubectl apply -f 3-clusterpolicy-statefulset-crashloopback-remove-label-mutation.yaml
kubectl apply -f 4-clusterpolicy-statefulset-scaledown-mutation.yaml
kubectl apply -f 5-clusterpolicy-delete-statefulset.yaml

# Verify policies are created
kubectl get clusterpolicy | grep statefulset
```

### Step 2: Deploy the Test StatefulSet

Deploy the sample StatefulSet that will enter CrashLoopBackOff:

```bash
kubectl apply -f sample-crashloop-statefulset.yaml
```

### Step 3: Monitor the StatefulSet

Watch the StatefulSet and its pods:

```bash
# Watch StatefulSet status
kubectl get statefulset crashloop-test-statefulset -w

# Watch pod status
kubectl get pods -l app=crashloop-test -w

# Check pod details and crash reason
kubectl describe pod crashloop-test-statefulset-0
```

### Step 4: Observe Policy Actions

Monitor the progression through the cleanup stages:

#### Stage 1: Wait for CrashLoopBackOff (2-3 minutes)
```bash
# Check if pods are in CrashLoopBackOff
kubectl get pods -l app=crashloop-test

# Expected output:
# NAME                           READY   STATUS             RESTARTS   AGE
# crashloop-test-statefulset-0   0/1     CrashLoopBackOff   5          3m
# crashloop-test-statefulset-1   0/1     CrashLoopBackOff   5          3m
```

#### Stage 2: Check for Marking (after 1 minute from CrashLoopBackOff)
```bash
# Check StatefulSet annotations
kubectl get statefulset crashloop-test-statefulset -o yaml | grep -A 5 annotations

# Expected annotations:
# sts-cleanup.resource: marked-for-action
# sts-timestamp: "2024-01-XX..."
```

#### Stage 3: Monitor Audit Alerts
```bash
# Check policy reports
kubectl get policyreport -A | grep statefulset

# Check events
kubectl get events --field-selector reason=PolicyViolation
```

#### Stage 4: Wait for Scale Down (after 5 minutes from marking)
```bash
# Check if StatefulSet is scaled to 0
kubectl get statefulset crashloop-test-statefulset

# Check for scale down annotation
kubectl get statefulset crashloop-test-statefulset -o yaml | grep sts-scaledowntimestamp
```

#### Stage 5: Wait for Deletion (after 30 seconds from scale down)
```bash
# Check if StatefulSet still exists
kubectl get statefulset crashloop-test-statefulset

# This should eventually return "No resources found"
```

### Step 5: Testing Recovery Scenario

To test the recovery mechanism, deploy a similar StatefulSet that will initially crash but then fix it:

```bash
# Deploy the crashing StatefulSet
kubectl apply -f sample-crashloop-statefulset.yaml

# Wait for it to be marked (check annotations)
kubectl get statefulset crashloop-test-statefulset -o yaml | grep sts-cleanup.resource

# Once marked, fix the StatefulSet by updating the container command
kubectl patch statefulset crashloop-test-statefulset -p '{"spec":{"template":{"spec":{"containers":[{"name":"crashloop-container","command":["/bin/sh","-c","echo Starting fixed container...; sleep 3600"]}]}}}}'

# Monitor the pods recovering
kubectl get pods -l app=crashloop-test -w

# Check that annotations are removed when pods are running
kubectl get statefulset crashloop-test-statefulset -o yaml | grep -A 5 annotations
```

## 🔍 Monitoring Commands

### Real-time Monitoring
```bash
# Watch all resources related to the test
watch 'kubectl get statefulset,pods -l app=crashloop-test'

# Monitor policy reports
watch 'kubectl get policyreport -A'

# Monitor events
kubectl get events --watch --field-selector reason=PolicyViolation
```

### Debugging Commands
```bash
# Check Kyverno logs
kubectl logs -n kyverno deployment/kyverno -f

# Check policy status
kubectl get clusterpolicy -o wide

# Describe StatefulSet for detailed events
kubectl describe statefulset crashloop-test-statefulset

# Check PVCs (they may persist after StatefulSet deletion)
kubectl get pvc
```

## 📊 Expected Timeline

| Time | Stage | Action | Observable |
|------|-------|--------|------------|
| 0min | Deploy | StatefulSet created | Pods starting |
| 1-2min | CrashLoop | Pods enter CrashLoopBackOff | Pod status shows crashes |
| 3min | Mark | Policy 1 marks StatefulSet | Annotations added |
| 3min | Alert | Policy 2 generates audit alert | PolicyReport created |
| 8min | Scale | Policy 4 scales to 0 replicas | Replicas = 0 |
| 8.5min | Delete | Policy 5 deletes StatefulSet | Resource removed |

## 🧹 Cleanup

After testing, clean up any remaining resources:

```bash
# Remove test StatefulSet (if still exists)
kubectl delete statefulset crashloop-test-statefulset --ignore-not-found

# Remove test service
kubectl delete service crashloop-test-service --ignore-not-found

# Remove any remaining PVCs
kubectl delete pvc -l app=crashloop-test

# Remove policies (optional)
kubectl delete clusterpolicy mark-statefulset-scale-down
kubectl delete clusterpolicy marked-statefulset-scale-down-validation
kubectl delete clusterpolicy remove-statefulset-scale-down-label
kubectl delete clusterpolicy scale-down-statefulset
kubectl delete clustercleanuppolicy cleanup-stale-statefulsets
```

## ⚠️ Important Notes

1. **PVC Persistence**: StatefulSet PVCs may persist after deletion. Clean them up manually if needed.
2. **Testing Environment**: Always test in a non-production environment first.
3. **Timing**: Adjust the timing values in policies for testing (shorter intervals) vs production (longer intervals).
4. **Resource Limits**: The test StatefulSet requests minimal resources but ensure your cluster has sufficient capacity.
5. **Backup**: Even in testing, consider backing up any important data before running cleanup policies.

## 🐛 Troubleshooting

### StatefulSet Not Getting Marked
- Check if pods are actually in CrashLoopBackOff: `kubectl get pods -l app=crashloop-test`
- Verify policy is active: `kubectl get clusterpolicy mark-statefulset-scale-down`
- Check Kyverno logs: `kubectl logs -n kyverno deployment/kyverno`

### Policies Not Triggering
- Ensure Kyverno has proper RBAC permissions
- Check if policies are in "Ready" state: `kubectl get clusterpolicy -o wide`
- Verify policy conditions are met

### Recovery Not Working
- Check if pods are actually running: `kubectl get pods -l app=crashloop-test`
- Verify the recovery policy is active: `kubectl get clusterpolicy remove-statefulset-scale-down-label`
- Check annotations manually: `kubectl get statefulset crashloop-test-statefulset -o yaml` 