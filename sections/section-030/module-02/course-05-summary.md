---
draft: true
---
# Summary

You moved a service from an Ingress to a Gateway and a route, and planned the switch.

## Key points

- Host, path, backend and TLS map to `hostnames`, `matches`, `backendRefs` and `certificateRefs`.
- The Ingress and the Gateway API can run side by side; each has its own Service and address.
- Annotations have no direct copy: replace them with filters and fields or decide what to drop.
- `ingress2gateway` gives a draft; review warnings and read the status.
- Compare both entry points with the same requests, switch in DNS, and keep the Ingress for the rollback.

## What to practise

Convert an Ingress with a TLS section and a redirect annotation, then run both and compare the answers.

<!-- astrona:playground:destroy -->
