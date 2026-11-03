# Question

Solve this question on: `terminal`

The platform team runs the `Gateway` `edge-gw` in the namespace `edge`. Its listener accepts routes only from its own namespace, so the `HTTPRoute` `scout` in `starfleet` is rejected. A second route, `outpost-probe` in `outpost`, also attaches to the Gateway.

Change the cluster so that:

1. The route `scout` in `starfleet` is accepted by `edge-gw`, and a request for `scout.example.com` through the Gateway returns the `scout` reply.
2. The platform team controls access with a namespace label. The listener of `edge-gw` accepts routes from the namespaces that carry the label `access=gateway`. Do not use `from: All`.
3. The route `outpost-probe` in `outpost` is not accepted. Do not label `outpost`.

The entry point of the Gateway on this cluster is the node port of the Service that Cilium created for it. You can send requests from the pod `shuttle` in `starfleet`. `kubectl` already points at the cluster.
