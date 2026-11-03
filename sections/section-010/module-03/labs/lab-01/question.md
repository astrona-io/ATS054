# Question

Solve this question on: `terminal`

The platform team runs the Gateway `fleet` in the namespace `starfleet`. It has one HTTPS listener named `https` for the host `scout.example.com`, and the HTTPRoute `scout` attaches to that listener. HTTPS requests do not work yet. A TLS certificate for the host is already stored in the cluster as a Secret. Fix the Gateway. Do not add listeners, do not change the port, the host name or the TLS mode, and do not change the route.

1. The certificate reference of the `https` listener must resolve.
2. The route `scout` must be accepted.
3. An HTTPS request for `scout.example.com` must reach the Service `scout`.

The entry point of the Gateway is the Service that Cilium created for it, `cilium-gateway-fleet`. Send test requests from the pod `shuttle` in `starfleet` with `curl`. `kubectl` already points at the cluster.
