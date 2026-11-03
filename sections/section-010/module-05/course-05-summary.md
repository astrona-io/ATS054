---
draft: true
---
# Summary

You found faults in a Cilium Gateway by reading from the top down.

## Key points

- Read the conditions in order: GatewayClass, Gateway, listener, route.
- `Accepted` is about attachment, `Programmed` about the data plane, `ResolvedRefs` about references.
- The CRDs must exist before the operator starts, and `gatewayAPI.enabled` must be on.
- Cilium creates the Service `cilium-gateway-<name>` and a `CiliumEnvoyConfig` for each Gateway.
- `404`, `503`, `502` and no answer point to different levels.
- Hubble shows drops, and backend policies must allow the `ingress` entity.

## What to practise

Break a route in three ways, one at a time, and name the condition and reason each one produces before you fix it.

<!-- astrona:playground:destroy -->
