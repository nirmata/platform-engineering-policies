## Installing Policies

**Clone Repository:**

Clone the repository.

```console
git clone https://github.com/nirmata/platform-engineering-policies.git
```

**Install Workload Security Policies:**

To install Workload Security Compliance policy


```console
cd kyverno-policies
kubectl apply -f workload-security
```

Once policies are installed, you can check if they are ready using the command:

```console
kubectl get cpol
```
