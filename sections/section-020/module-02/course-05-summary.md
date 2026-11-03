---
draft: true
---
# Summary

You moved Service traffic from the kernel to the Cilium Envoy proxy and chose the right tool for each need.

## Key points

- The kernel balances per connection; Envoy balances per request.
- The annotation `service.cilium.io/lb-l7=enabled` hands a Service to Envoy, and needs `loadBalancer.l7.backend=envoy`.
- The algorithm is `round_robin`, `least_request` or `random`.
- A `CiliumEnvoyConfig` holds a listener, a route configuration and a cluster.
- Weights and retries are Envoy route settings, and weights are also in the Gateway API.
- Use the simplest tool: annotation, then Gateway API, then `CiliumEnvoyConfig`.

## What to practise

Annotate a Service, switch the algorithm and measure which pods answer with and without slow requests.

<!-- astrona:playground:destroy -->
