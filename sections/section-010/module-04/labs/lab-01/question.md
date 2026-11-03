# Question

Solve this question on: `terminal`

The platform team runs a `Gateway` named `fleet` in the namespace `starfleet`. The application team has an `HTTPRoute` named `fleet` for the host `fleet.example.com` that sends every request to the Service `scout`. Two changes are due. Edit the route only. Do not change the `Gateway` and do not create more routes.

1. Requests whose path starts with `/old` must get a permanent redirect (status `301`) to the host `probe.example.com`.
2. Requests whose path starts with `/probe` must go to the Service `probe` on port 80, and `probe` must see the path without the `/probe` prefix. For example `/probe/uuid` must arrive as `/uuid`.
3. All other requests must keep reaching `scout`.

The entry point of a Gateway on this cluster is the node port of the Service that Cilium created for it, `cilium-gateway-fleet`. You can send test requests from the pod `shuttle` in `starfleet` with `curl` and a `Host` header. `kubectl` already points at the cluster.
