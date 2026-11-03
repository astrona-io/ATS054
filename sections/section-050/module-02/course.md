---
draft: true
---
# Sidecarless Architecture In Practice

Reading that "Cilium has no sidecars" is easy. Proving it in your own cluster, measuring what it costs and knowing what happens when a part fails takes work. This module does that work with a running cluster.

Keep one sentence in mind for this module: **in the sidecarless design the proxy count follows the node count, not the pod count, so cost, upgrades and failures are all measured per node.** You will list what runs where, compare the footprint of a pod count with a node count, restart the proxy while traffic runs, and weigh the security trade-offs.

The module has four parts. **What Runs Where** lists the pieces and their places. **Cost And Footprint** compares resource use. **Upgrades And Failure Scope** restarts a part and reads the effect. **Security Boundaries And Trade-offs** covers what a shared proxy changes.

## Learning objectives

After this module you can:

- List the Cilium components and the node or pod that runs each.
- Compare the footprint of a sidecar per pod with a proxy per node.
- Explain what an upgrade or a failure of the node proxy affects.
- State the security trade-offs of a shared proxy.

## Before you start

You need the idea of the sidecarless design from the first module of this section.

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
