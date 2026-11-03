---
draft: true
---
# Service Mesh Use Cases With Cilium

Many services that call each other need the same things: a way to control which service may call which, a way to route and split requests, and a way to see what happens on every call. A service mesh is a layer of infrastructure that provides these functions for the traffic between services, so the application code does not have to implement them. This module names the use cases, shows which Cilium component delivers each one, and applies two of them in a cluster: Layer 7 access control and traffic observation.

Keep one sentence in mind for this module: **a mesh use case is a rule about requests between services, and Cilium enforces the rule in the kernel with eBPF for Layer 3 and Layer 4 and in an Envoy proxy on the node for Layer 7.** You will separate the use cases that need only the kernel from the ones that need the proxy, write an HTTP rule that allows one method and path, and read the result in Hubble.

The module has three parts. **What A Service Mesh Does** groups the use cases into traffic management, security and observability, and shows where Cilium runs each one. **Layer 7 Access Control With CiliumNetworkPolicy** writes an HTTP rule and explains what Envoy does with a request that breaks it. **Observing Service Traffic With Hubble** reads flows, verdicts and HTTP metadata, and uses them to prove a policy works.

## Learning objectives

After this module you can:

- Name the three groups of service mesh use cases and give two examples of each.
- Decide whether a use case needs only Layer 3 and Layer 4 enforcement or also a Layer 7 proxy.
- Explain what the Cilium agent, the Cilium Envoy proxy and eBPF each do for a request.
- Write a `CiliumNetworkPolicy` that allows one HTTP method and path from one client and nothing else.
- Tell apart a request that Envoy denies (HTTP `403`) from a packet that the kernel drops (no reply).
- Read Hubble flows to find the source, the destination, the verdict and the HTTP details of a request.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, labels and `kubectl exec`. You also need to know the OSI layers at a basic level: Layer 3 is IP, Layer 4 is TCP and UDP, and Layer 7 is the application protocol, here HTTP.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Cilium Envoy proxy and Hubble with Hubble Relay. No sidecar proxy runs in any pod. No `CiliumNetworkPolicy` exists yet, so every pod can reach every other pod.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 and pod port 9898 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 and pod port 8080 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A client pod with `curl` in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
