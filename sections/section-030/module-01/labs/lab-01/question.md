---
draft: true
exam_objectives:
- Understand the Benefits of Gateway API over Ingress
---
# Separate Internal Service Ownership From Gateway Delegation

Verify internal Service ownership and realised endpoints.

## Starting state

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-054-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-054-lab-030-01-01" || exit 1
node_name="astro-ats-054-lab-030-01-01-control-plane"
worker_name="astro-ats-054-lab-030-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Inspect the probe Service selector and prove it reaches healthy endpoints. Gateway route attachment and delegated cross-namespace references remain a distinct production concern.

Record observations in `starfleet/evidence`, whose `report.json` contains the stated report. The verifier reads the live API again; invented values do not pass.

The report object uses these fields: `selector`, `ports`, `response`. Keep numeric values numeric and preserve arrays and nested objects returned by the API.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
