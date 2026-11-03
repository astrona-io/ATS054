# Question

Solve this question on: `terminal`

The namespace `starfleet` has an `Ingress` named `fleet` for the host `fleet.example.com`. It sends the path prefix `/probe` to the Service `probe` and every other path to the Service `scout`, both on port 80. The team moves to the Gateway API.

1. Create a `Gateway` named `fleet` in `starfleet` with one HTTP listener on port 80, using the GatewayClass `cilium`. It must accept routes from its own namespace only.
2. Create an `HTTPRoute` named `fleet` that does the same routing as the Ingress, for the same host.
3. When the Gateway routes correctly, delete the `Ingress`.

The entry point of a Gateway on this cluster is the node port of the Service that Cilium created for it, `cilium-gateway-fleet`. You can send test requests from the pod `shuttle` in `starfleet` with `curl` and a `Host` header. `kubectl` already points at the cluster.
