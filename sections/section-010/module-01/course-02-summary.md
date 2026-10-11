---
draft: true
exam_objectives:
- Know How to use Ingress or Gateway API for Ingress Routing
---
# Summary

Ingress and Gateway resources describe external request routing, while Cilium's enabled implementation translates that intent into listener and proxy behavior. Host, path, protocol and backend relationships must agree.

Resource acceptance and a reachable address are partial evidence. TLS termination protects its defined segment rather than every downstream hop, and endpoint readiness or policy can still prevent useful application service.
