---
draft: true
---
# Summary

A service mesh provides traffic management, security and observability for the requests between services, so that application code does not need to. Cilium delivers each use case with the cheapest component that can do it. eBPF programs in the kernel enforce Layer 3 and Layer 4 rules and balance Services. The Cilium agent turns policies and labels into identities and eBPF rules. The Envoy proxy, which runs once on each node, handles Layer 7 rules and routing.

A `CiliumNetworkPolicy` that selects a pod switches that pod to deny by default for the direction it names, and every rule allows traffic. A Layer 4 rule names the clients and the ports. A Layer 7 rule adds `rules.http` with `method`, `path`, `host` and `headers`, and the values are regular expressions. For a pod and port with an HTTP rule, eBPF redirects allowed connections to Envoy, and Envoy checks each request.

The type of failure tells which component acted. A request from a client that no rule allows is dropped by the kernel and ends in a timeout. A request from an allowed client that no HTTP entry matches gets an HTTP `403` from Envoy with the body `Access denied`. A request that matches a rule reaches the pod.

Hubble records flows with a source, a destination and a verdict. It reads Layer 3 and Layer 4 flows from eBPF, and it adds HTTP details for traffic that went through Envoy. Hubble Relay collects the flows of all nodes. Filtering by namespace, pod, verdict and protocol turns a policy into something you can prove.

- The three groups of use cases are traffic management, security and observability.
- Layer 7 processing costs latency and CPU on the node, so use it only where a rule needs it.
- Write the pod port, not the Service port, in `toPorts`.
- A timeout points to the kernel, and a `403` points to Envoy.
- `DROPPED` is a Hubble verdict, and an HTTP `403` is a response code.

<!-- astrona:playground:destroy -->
