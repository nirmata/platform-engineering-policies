# Kyverno Policy: Restrict NetworkPolicy Modifications

## Overview

This repository contains a Kyverno `ClusterPolicy` designed to enhance the security and integrity of your Kubernetes cluster by restricting the creation, modification, and deletion of `NetworkPolicy` resources. Only users assigned the `cluster-admin` role are permitted to perform these actions.

## Policy Details

The policy, named `restrict-networkpolicy-modifications`, enforces the following:

- **Scope**: Applies to all `NetworkPolicy` resources across the cluster.
- **Operations Restricted**:
  - `CREATE`
  - `UPDATE`
  - `DELETE`
- **Exemption**: Users with the `cluster-admin` role are exempt from these restrictions.

## Policy Definition

Below is the Kyverno policy YAML:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-networkpolicy-modifications
  annotations:
    policies.kyverno.io/title: Restrict NetworkPolicy Modifications
    policies.kyverno.io/category: Security
    policies.kyverno.io/subject: NetworkPolicy
    policies.kyverno.io/description: >
      This policy prevents users from creating, editing, or deleting NetworkPolicy resources
      unless they have the cluster-admin role.
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: block-networkpolicy-changes
      match:
        any:
          - resources:
              kinds:
                - NetworkPolicy
      exclude:
        any:
          - clusterRoles:
              - cluster-admin
      validate:
        message: "Creating, modifying, or deleting NetworkPolicy resources is restricted to cluster-admins."
        deny:
          conditions:
            any:
              - key: "{{request.operation}}"
                operator: AnyIn
                value:
                  - CREATE
                  - UPDATE
                  - DELETE

