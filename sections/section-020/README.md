---
draft: true
exam_objectives:
- Service Mesh Use Cases
---
# Service Mesh Use Cases

This section names the use cases of a service mesh and shows which Cilium component delivers each one. It applies Layer 7 access control with a CiliumNetworkPolicy and reads the verdicts of the traffic in Hubble.

## Learning Outcomes

- Name the mesh use cases: traffic management, security and observability.
- Say which use cases need only the kernel and which need the Envoy proxy.
- Write an HTTP rule that allows one method and path, and explain why a denied request gets 403 or no reply.
- Read flows and verdicts with Hubble.

## Learning Path

The section has one module, **Service Mesh Use Cases With Cilium**, with these parts in order:

1. What A Service Mesh Does
2. Layer 7 Access Control With CiliumNetworkPolicy
3. Observing Service Traffic With Hubble

The module has an ungraded playground, a graded lab (**Apply Layer 7 Access Control With CiliumNetworkPolicy**) and a summary. The section closes with a capstone lab (**Repair Layer 7 Policies Without A Sidecar**) and a knowledge check. The labs are untested and checked statically only.
