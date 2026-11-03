# Question

Solve this question on: `terminal`

The team of `drifter` published the `HTTPRoute` `probe` in the namespace `outpost` for the host `probe.example.com`. It attaches to the `Gateway` `edge-gw` in `edge` and sends requests to the Service `probe` in `starfleet`. Requests for this host do not work.

Make the route work without changing the Gateway and without moving the route:

1. The route must be accepted by the Gateway. The platform team lets a namespace attach by a label, which the Gateway already selects.
2. The backend reference must resolve. The owner of the Service `probe` allows the reference with a `ReferenceGrant` in `starfleet`. The grant must allow only `HTTPRoute` resources from the namespace `outpost` and only the Service named `probe`.
3. A request with the host `probe.example.com` sent to the Gateway must return the reply of `probe`.

The entry point of the Gateway on this cluster is the node port of the Service that Cilium created for it. You can send requests from the pod `shuttle` in `starfleet`. `kubectl` already points at the cluster.
