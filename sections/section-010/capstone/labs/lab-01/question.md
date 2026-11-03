# Question

Solve this question on: `terminal`

Two teams publish services on this cluster. Both are broken. Fix them without editing the `Gateway`.

1. The team of `scout` created the `Ingress` `scout` in `starfleet` for the host `scout.example.com`, but Cilium ignores it. Make Cilium serve it. Keep the rule as it is.
2. The team of `probe` created the `HTTPRoute` `probe` in `starfleet` for the host `probe.example.com`. It points at the `Gateway` `edge-gw` in the namespace `edge`, and the Gateway does not accept it. The platform team's Gateway only accepts routes from namespaces that carry the label `access=gateway`. Make the route accepted. Do not change the Gateway and do not move the route.

Both entry points must answer requests with the right `Host` header: `scout.example.com` returns the `scout` reply and `probe.example.com` returns the `probe` reply.

The entry point of each resource on this cluster is the node port of the Service that Cilium created for it. You can send requests from the pod `shuttle` in `starfleet`. `kubectl` already points at the cluster.
