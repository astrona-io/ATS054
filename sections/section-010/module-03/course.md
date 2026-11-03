---
draft: true
---
# Gateway Listeners, TLS And Route Types

A Gateway is the entry point that a platform team owns. Its listeners decide which ports, protocols and host names the entry point accepts, which certificates it presents and which routes may attach. Routes then describe where requests go. Most faults in a Gateway setup sit in the listener, so a learner who can read a listener can fix most problems.

Keep one sentence in mind for this module: **a listener is a port, a protocol and an optional host name, plus rules for which routes may attach and which certificate to present, and the status of the listener says whether Cilium accepted each part.** You will read listener fields, serve HTTPS with a certificate Secret, share a certificate across namespaces with a `ReferenceGrant`, choose between TLS termination and passthrough, and read the status of listeners.

The module has four parts. **Listeners And Attachment** covers the listener fields and how a route attaches. **HTTPS Listeners And Certificates** terminates TLS and explains cross-namespace references. **TLS Passthrough And Route Kinds** covers the `Passthrough` mode, `TLSRoute` and `GRPCRoute`. **Reading Listener Status** reads the conditions that tell why a listener or route fails.

## Learning objectives

After this module you can:

- Write a `Gateway` with several listeners that differ by port, protocol and host name.
- Restrict the routes that attach to a listener by namespace and by kind.
- Serve HTTPS with `tls.mode: Terminate` and a `certificateRefs` entry, and test it with `curl --resolve`.
- Explain why a certificate in another namespace needs a `ReferenceGrant`.
- Choose between `Terminate` and `Passthrough` and name the route kind each one uses.
- Read `Accepted`, `Programmed`, `ResolvedRefs` and `attachedRoutes` in a Gateway status.

## Before you start

You need the basics of the Gateway API: `GatewayClass`, `Gateway` and `HTTPRoute`. You also need to know what a TLS certificate and a Kubernetes Secret are, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. `openssl` must be available in your terminal.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement and the Gateway API controller. The experimental channel of the Gateway API CRDs is installed, so `TLSRoute` and `GRPCRoute` exist. The `GatewayClass` is named `cilium`. You reach a Gateway through the node IP address and the node port of its Service from the `shuttle` pod.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

No `Gateway` exists yet. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
