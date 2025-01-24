## Installing Policies

**Clone Repository:**

Clone the repository.

```console
git clone https://github.com/nirmata/platform-engineering-policies.git
```

**Install FinOps Policies:**

To install FinOps Compliance policy


```console
cd platform-engineering-policies
kubectl apply -f Finops
```

Once policies are installed, you can check if they are ready using the command:

```console
kubectl get cpol
```
