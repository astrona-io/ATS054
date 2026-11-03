---
draft: true
---
# Traffic Management With The Cilium Envoy Proxy

By default Cilium balances a Service in the kernel, one connection at a time. That is fast, but it cannot see requests. Many applications keep one long-lived connection and send thousands of requests over it, so a connection-level balancer sends all of them to one pod. The Cilium Envoy proxy balances each request, retries failed ones and splits traffic by weight, without a sidecar in your pods.

Keep one sentence in mind for this module: **a Service handled in the kernel is balanced per connection, a Service handed to the Cilium Envoy proxy is balanced per request, and a `CiliumEnvoyConfig` lets you write the Envoy rules yourself.** You will turn on Layer 7 load balancing with an annotation, pick an algorithm, read a `CiliumEnvoyConfig`, and decide when to use it and when to use the Gateway API instead.

The module has four parts. **Layer 7 Load Balancing With An Annotation** hands a Service to Envoy. **Choose A Balancing Algorithm** compares `round_robin`, `least_request` and `random`. **CiliumEnvoyConfig Anatomy** reads the resource that carries Envoy rules. **Weights, Retries And When To Use Which Tool** adds traffic splitting and retries, and compares the tools.

## Learning objectives

After this module you can:

- Explain the difference between per-connection and per-request load balancing.
- Turn on Layer 7 load balancing for a Service with annotations.
- Choose between `round_robin`, `least_request` and `random`.
- Name the parts of a `CiliumEnvoyConfig` and the difference between namespaced and clusterwide.
- Choose between a Service annotation, a `CiliumEnvoyConfig` and the Gateway API.

## Before you start

You need Services, labels and `kubectl exec`, and the idea of a CiliumNetworkPolicy from the previous module.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Cilium Envoy proxy, Hubble and Layer 7 load balancing handled by Envoy (the Helm value `loadBalancer.l7.backend=envoy`).

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
