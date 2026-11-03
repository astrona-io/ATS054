# Question

Solve this question on: `terminal`

The `Gateway` named `fleet` in the namespace `starfleet` has one listener named `web` for the host `*.example.com`. The `HTTPRoute` named `fleet` was written for the host `fleet.example.com` and should send every request to the Service `scout`. It does not work. Find out why and repair it.

Edit the route only. Do not change the `Gateway` and do not create more routes.

When you are done, the route must be `Accepted`, its references must resolve, and a request with the `Host` header `fleet.example.com` must reach `scout`.

The entry point of a Gateway on this cluster is the node port of the Service that Cilium created for it, `cilium-gateway-fleet`. You can send test requests from the pod `shuttle` in `starfleet` with `curl`. `kubectl` already points at the cluster.
