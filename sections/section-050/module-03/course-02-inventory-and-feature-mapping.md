---
draft: true
---
# Inventory And Feature Mapping

You cannot migrate what you have not counted. The inventory is a set of numbers and lists. The mapping says what replaces each feature that the old mesh gave you.

## The inventory

Collect these facts before you change anything:

- **Injection**: which namespaces have the label or the annotation that makes the old mesh inject a proxy.
- **Sidecar pods**: how many pods have a proxy container, and in which namespaces.
- **Mesh objects**: the routes, policies and gateways of the old mesh.
- **Layer 7 policies**: the Cilium policies that already use HTTP rules, because they rely on the node proxy.
- **Node proxy readiness**: `cilium-envoy` must be ready on every node.
- **Owners**: who to ask for each namespace.

<!-- astrona:playground:renew -->

```sh
kubectl get namespaces -l sidecar.example.io/inject=true
kubectl get cnp -A
kubectl -n kube-system get daemonset cilium-envoy
```

In the playground no namespace has the label, and there is no policy yet. In the lab you work with a cluster that does.

## The mapping

| Old mesh feature | In Cilium |
| --- | --- |
| Mutual TLS between pods | WireGuard or IPsec for the traffic, and mutual authentication in policies for the identity |
| Authorization policy by service account or path | `CiliumNetworkPolicy` with identity selectors and HTTP rules |
| Retries, timeouts, weights | Envoy features through Gateway API routes or `CiliumEnvoyConfig` |
| Ingress gateway | Cilium Ingress or Gateway API |
| Metrics and traces for requests | Hubble and its metrics |
| Per-service circuit breaking | Not the same: check the Cilium documentation for the equivalent |

Fill the right column for each feature your services use. A row with no equivalent is a gap: record it, and keep the sidecar for that workload or accept the loss.

## Common pitfalls

> [!WARNING]
> Do not map features by name alone. "Mutual TLS" in one mesh and "mutual authentication" in Cilium are different things: one encrypts each connection in the proxy, the other proves identity and relies on another feature for encryption. Write what the guarantee is, then match it.
