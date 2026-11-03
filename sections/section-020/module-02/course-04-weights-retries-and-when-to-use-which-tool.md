---
draft: true
---
# Weights, Retries And When To Use Which Tool

Traffic management has three parts that matter in practice: splitting traffic by weight, retrying failed requests and choosing the right tool for each. This part shows how each one is expressed and compares the three ways to get them in Cilium.

## Weighted split and retries in Envoy terms

In Envoy configuration, a weighted split is a route whose action lists several clusters with a `weight` each, and a retry policy is a `retry_policy` on a route with the conditions to retry on, such as `5xx` or `connect-failure`, and a number of retries. In a `CiliumEnvoyConfig` you write these in the `RouteConfiguration`. The Cilium documentation has an example that splits a Service between two versions.

## The same in the Gateway API

With the Gateway API you get the split from the field `weight` of `backendRefs`, as you saw in the module on HTTPRoute filters. You do not write Envoy objects, and Cilium translates the route for you. Retries are an extension in the Gateway API; check the status of that feature in the Gateway API version you use before you rely on it.

## Three tools, three jobs

| Need | Best tool | Why |
| --- | --- | --- |
| Per-request balancing for a Service | Annotation `service.cilium.io/lb-l7` | One line, no new objects |
| North-south routing, filters, weights | Gateway API | Portable and supported |
| Envoy feature the others lack | `CiliumEnvoyConfig` | Full control, high cost |

Start with the simplest tool that meets the need. Move up only when it cannot.

## Observe the result

Whatever tool you use, check the result with real traffic and Hubble. Run `hubble observe --protocol http --namespace starfleet` while you send requests, and see the HTTP method, path and status of each call, then count which pod answered.

## Common pitfalls

> [!WARNING]
> Do not mix an annotation and a hand-written `CiliumEnvoyConfig` for the same Service without testing: both want to own the traffic. Retries repeat a request, so use them only for requests that are safe to repeat. A weight is a share, not a percentage, as in the Gateway API.
