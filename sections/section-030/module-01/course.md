---
draft: true
---
# Gateway API Compared With Ingress

An Ingress holds the listener, the routes and the certificate in one object, and it has no field for header matching, traffic splitting or request changes. The Gateway API replaces it with separate resources that different teams own, and with fields for the things that Ingress leaves to annotations. This module shows what an Ingress cannot do, how the Gateway API splits roles and delegates access, and what the API makes portable between controllers.

Keep one sentence in mind for this module: **the Gateway API puts the entry point in a Gateway that the platform team owns and the routing rules in routes that the application teams own, and it lets the platform team decide who may attach.** You will create a Gateway that accepts routes only from labelled namespaces, see a route rejected and then accepted, and build a route with a header match and a filter.

The module has three parts. **The Limits Of Ingress** shows what one Ingress object holds and what it cannot express. **Gateway API Roles And Delegation** names the three roles, attaches routes with `allowedRoutes` and shares backends with `ReferenceGrant`. **Expressiveness And Portability** builds a route with a match and a filter and explains the channels and conformance that make the API portable.

## Learning objectives

After this module you can:

- List what an Ingress can express and three things that need controller-specific annotations.
- Name the GatewayClass, Gateway and HTTPRoute resources and the role that owns each.
- Control which namespaces attach routes with `allowedRoutes` and a namespace label.
- Allow a route to use a Service in another namespace with a `ReferenceGrant`.
- Read `Accepted` and `ResolvedRefs` conditions to find why a route does not work.
- Write a route with a header match and a request filter.

## Before you start

You need Kubernetes basics: namespaces, labels, Services and `kubectl`. You should know what an Ingress is and that a controller turns it into a running proxy.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Cilium Ingress controller and the Cilium Gateway API controller. The Gateway API CRDs are installed. No Ingress, Gateway or route exists yet.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A client pod with `curl` in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
