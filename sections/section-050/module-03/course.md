---
draft: true
---
# Choose And Migrate A Mesh Architecture

Knowing how the designs work is half of the job. The other half is deciding which one fits a workload and moving to it without an outage. This module gives a way to decide, a plan for a migration from sidecars to the Cilium node proxy, and a way to verify and undo each step.

Keep one sentence in mind for this module: **a migration is a series of small, reversible steps that each have a check, not one big switch.** You will list decision factors, build an inventory, map features from the old mesh to Cilium, move one namespace at a time and keep a way back.

The module has four parts. **Decision Factors** gives a table of questions. **Inventory And Feature Mapping** lists what to count and how to map it. **Migrate One Namespace At A Time** gives the order of steps. **Verify And Roll Back** gives the checks and the way back.

## Learning objectives

After this module you can:

- Choose between sidecar and sidecarless designs for a workload with stated reasons.
- Build an inventory of injection, sidecar pods and Layer 7 policies.
- Map features of a sidecar mesh to Cilium features.
- Migrate one namespace with a check and a rollback for each step.

## Before you start

You need the designs from the previous module and policies from the section on service mesh.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the `cilium-envoy` DaemonSet and Hubble.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
