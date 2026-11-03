---
draft: true
---
# Sidecar And Sidecarless Mesh Architectures

A service mesh needs a proxy that sees the requests between services. The big design question is where that proxy runs. It can run in every pod, on every node, or in a separate shared deployment, and each choice changes the cost, the upgrade process, the failure scope and the security boundary. This module explains the sidecar design, the sidecarless design of Cilium and the ambient design, and it shows in a cluster what Cilium puts where.

Keep one sentence in mind for this module: **the design decides who pays for the proxy, who upgrades it and who is affected when it fails, so compare designs on those three points and not on their names.** You will list the containers of pods, find the Envoy pods of Cilium, apply a Layer 7 rule without changing a pod, and restart the proxy without restarting the application.

The module has three parts. **How A Sidecar Mesh Works** explains injection, traffic redirection and the costs of a proxy in every pod. **Cilium Sidecarless Architecture** explains the kernel, the agent and the node-level Envoy. **Comparing Sidecar, Sidecarless And Ambient Designs** compares resources, upgrades, failure scope and security boundaries.

## Learning objectives

After this module you can:

- Explain how a sidecar is injected and how traffic is redirected to it.
- Name the pieces of the Cilium architecture and say where each runs.
- Describe which traffic reaches Envoy and which stays in the kernel.
- Compare sidecar, Cilium and ambient designs on resource use, upgrades, failure scope and security boundary.
- Separate a design label from a security guarantee.

## Before you start

You need Kubernetes basics: Deployments, DaemonSets, namespaces and `kubectl exec`. A rough idea of what a proxy does helps.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Envoy DaemonSet and Hubble.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 and pod port 9898 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 and pod port 8080 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A client pod with `curl` in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
