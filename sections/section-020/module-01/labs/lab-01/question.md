---
draft: true
exam_objectives:
- Service Mesh Use Cases
---
# Apply Mesh Style L7 Access Control

Enforce a service HTTP path boundary.

## Starting state

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-054-lab-020-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-054-lab-020-01-01" || exit 1
node_name="astro-ats-054-lab-020-01-01-control-plane"
worker_name="astro-ats-054-lab-020-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Enforce a path-aware service boundary with Cilium. Compare this network enforcement with application identity and mesh-level retries; the latter are not implemented by this fixture.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
