---
draft: true
---
# HTTPRoute Filters And Traffic Management

An `HTTPRoute` does more than send a request to a backend. A rule can match on the path, the headers, the query string and the method. It can change the request on its way, answer with a redirect, copy the request to a second backend, or share traffic between versions of a service by weight. Cilium turns each of these into Envoy configuration, so the work happens in the Envoy proxy on the node and not in the application.

Keep one sentence in mind for this module: **a rule is a list of matches, a list of filters and a list of weighted backends, and the Gateway picks the most specific matching rule for each request before it applies the filters of that rule.** You will write the four kinds of match, change headers, redirect, rewrite and mirror requests, and split traffic between two versions.

The module has four parts. **Request Matching And Rule Precedence** covers the four match types and the order in which rules win. **Header Modifiers And Redirects** changes headers and answers with `301` or `302`. **URL Rewrite And Request Mirroring** changes the path or host that the backend sees and copies traffic to a second backend. **Weighted Backends For Canary And Blue-Green** shifts traffic gradually and rolls it back.

## Learning objectives

After this module you can:

- Match requests by path, header, query parameter and method, and predict which rule wins when several match.
- Add, set and remove request and response headers with the header modifier filters.
- Answer with a redirect that changes the scheme, the host or the path, and choose its status code.
- Rewrite the path prefix or the host name before the request reaches the backend.
- Mirror requests to a second backend without changing the client reply.
- Split traffic by weight and roll a canary back by changing one number.

## Before you start

You need the basics of the Gateway API: `Gateway`, `listener` and `HTTPRoute` with `parentRefs`, `hostnames` and `backendRefs`. You also need the commands `kubectl get`, `kubectl apply` and `kubectl logs`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement and the Gateway API controller. The `GatewayClass` is named `cilium`. The go-httpbin service `probe` has the paths `/headers`, `/get`, `/uuid` and `/status/<code>`, which echo what the backend received. You reach a Gateway through the node IP address and the node port of its Service from the `shuttle` pod.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

No `Gateway` exists yet. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
