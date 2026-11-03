# Question

Solve this question on: `terminal`

The platform team published the Ingress `scout` in the namespace `starfleet` for the host `scout.example.com`. The team wants the host served over HTTPS, but the Ingress does not work over HTTPS yet. A TLS certificate for the host is already stored in the cluster. Fix the Ingress. Do not create a new Ingress and do not change its rule.

1. The `tls` entry of the Ingress must name the TLS Secret that exists in `starfleet` and must cover `scout.example.com`.
2. An HTTPS request for `scout.example.com` must reach the Service `scout`.
3. A plain HTTP request for `scout.example.com` must be redirected to HTTPS.

The Ingress is served by Cilium in dedicated mode, so the entry point is the Service that Cilium created for it, `cilium-ingress-scout`. You can send test requests from the pod `shuttle` in `starfleet` with `curl`. `kubectl` already points at the cluster.
