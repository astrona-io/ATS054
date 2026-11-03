# Question

Solve this question on: `terminal`

The platform team runs a `Gateway` named `fleet` in the namespace `starfleet`. An application team wrote an `HTTPRoute` named `fleet` for the host `fleet.example.com`. The route does not work yet. Fix it and extend it. Do not change the `Gateway`, and do not create more routes.

1. The route must be accepted by the Gateway and all of its backend references must resolve. Every request for `fleet.example.com` must reach the Service `scout` in `starfleet`.
2. A request for `fleet.example.com` with the header `x-fleet: probe` must reach the Service `probe` in `starfleet` instead.

The entry point of a Gateway on this cluster is the node port of the Service that Cilium created for it. You can send test requests from the pod `shuttle` in `starfleet` with `curl` and a `Host` header. `kubectl` already points at the cluster.
