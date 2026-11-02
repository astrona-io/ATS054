---
draft: true
exam_objectives:
- Encrypting Traffic in Transit with Cilium
---
# Enable Cross Node WireGuard Encryption

Enable WireGuard and verify agent encryption state and cross-node requests.

## Starting state

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-054-lab-040-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-054-lab-040-01-02" || exit 1
node_name="astro-ats-054-lab-040-01-02-control-plane"
worker_name="astro-ats-054-lab-040-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Upgrade only the private Cilium release with encryption enabled and type wireguard. Schedule the probe on the control-plane node and shuttle on the worker, then check actual agent encryption state. The kind node kernel must support WireGuard; this exercise does not alter the physical host kernel.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
