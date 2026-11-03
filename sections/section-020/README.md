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
- Turn on Layer 7 load balancing, restrict egress by name and entity, and choose Hubble filters and metrics.

## Learning Path

The section has four modules. The first, **Service Mesh Use Cases With Cilium**, has these parts in order:

1. What A Service Mesh Does
2. Layer 7 Access Control With CiliumNetworkPolicy
3. Observing Service Traffic With Hubble

The second, **Traffic Management With The Cilium Envoy Proxy**, has these parts in order:

1. Layer 7 Load Balancing With An Annotation
2. Choose A Balancing Algorithm
3. CiliumEnvoyConfig Anatomy
4. Weights, Retries And When To Use Which Tool

The third, **Security Use Cases With Cilium**, has these parts in order:

1. Default Deny And Identity-Based Rules
2. Egress To Names And Entities
3. Deny Rules And Policy Precedence
4. Mutual Authentication In Policies

The fourth, **Observability With Hubble And Metrics**, has these parts in order:

1. Read Flows With The Hubble CLI
2. Filter Flows To Find A Fault
3. Layer 7 Visibility And Service Maps
4. Metrics For Prometheus

Each module has an ungraded playground, a graded lab (**Apply Layer 7 Access Control With CiliumNetworkPolicy**, **Turn On Layer 7 Load Balancing For A Service**, **Restrict The Egress Of A Pod With A CiliumNetworkPolicy** and **Make HTTP Requests Visible To Hubble**) and a summary. The section closes with a capstone lab (**Repair Layer 7 Policies Without A Sidecar**) and a knowledge check. The labs are untested and checked statically only.
