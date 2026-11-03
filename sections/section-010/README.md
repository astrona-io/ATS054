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
- Read route and Gateway conditions, check the controller prerequisites, and trace a failing request through Envoy and Hubble.
- Configure Gateway listeners and certificates, and use filters, rewrites, mirrors and weights on an HTTPRoute.

## Learning Path

The section has five modules. The first, **Route External Traffic With Cilium Ingress And Gateway API**, has these parts in order:

1. The Cilium Ingress Controller
2. Gateway API Resources In Cilium
3. Matching, Splitting And Debugging Routes

The second, **Cilium Ingress In Depth**, has these parts in order:

1. Shared And Dedicated Entry Points
2. Host And Path Matching
3. TLS Termination With A Secret
4. Reaching The Entry Point From Outside

The third, **Gateway Listeners, TLS And Route Types**, has these parts in order:

1. Listeners And Attachment
2. HTTPS Listeners And Certificates
3. TLS Passthrough And Route Kinds
4. Reading Listener Status

The fourth, **HTTPRoute Filters And Traffic Management**, has these parts in order:

1. Request Matching And Rule Precedence
2. Header Modifiers And Redirects
3. URL Rewrite And Request Mirroring
4. Weighted Backends For Canary And Blue-Green

The fifth, **Troubleshoot Cilium Ingress And Gateway**, has these parts in order:

1. Read The Status Conditions
2. Check The Controller And Its Prerequisites
3. Look Inside Envoy
4. Follow The Request With Hubble And A Fault Checklist

Each module has an ungraded playground, a graded lab (**Fix And Extend A Cilium Gateway Route**, **Fix TLS On A Cilium Ingress**, **Fix An HTTPS Listener On A Cilium Gateway** **Add A Redirect And A Rewrite To An HTTPRoute** and **Repair A Broken Gateway Route**) and a summary. The section closes with a capstone lab (**Publish Two Services With Cilium Ingress And Gateway API**) and a knowledge check. The labs are untested and checked statically only.
