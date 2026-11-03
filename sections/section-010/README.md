---
draft: true
exam_objectives:
- Know How to use Ingress or Gateway API for Ingress Routing
---
# Know How to use Ingress or Gateway API for Ingress Routing

This section teaches how to publish services from a Cilium cluster. It covers the Cilium Ingress controller, the Gateway API resources that Cilium implements, how a request travels from a listener through a route to a backend, and how to match, split and debug routes.

## Learning Outcomes

- Describe how the Cilium Ingress controller turns an Ingress into a proxy and a Service.
- Name the Gateway API resources and the role that owns each one.
- Trace a request through the listener, the route and the backend.
- Match requests by host, path and header, split traffic by weight, and read route status to find a fault.
- Choose the load balancer mode and Service type of an Ingress, match with the three path types, and terminate TLS with a Secret.

## Learning Path

The section has two modules. The first, **Route External Traffic With Cilium Ingress And Gateway API**, has these parts in order:

1. The Cilium Ingress Controller
2. Gateway API Resources In Cilium
3. Matching, Splitting And Debugging Routes

The second, **Cilium Ingress In Depth**, has these parts in order:

1. Shared And Dedicated Entry Points
2. Host And Path Matching
3. TLS Termination With A Secret
4. Reaching The Entry Point From Outside

Each module has an ungraded playground, a graded lab (**Fix And Extend A Cilium Gateway Route** and **Fix TLS On A Cilium Ingress**) and a summary. The section closes with a capstone lab (**Publish Two Services With Cilium Ingress And Gateway API**) and a knowledge check. The labs are untested and checked statically only.
