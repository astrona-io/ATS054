---
draft: true
---
# Troubleshoot Cilium Ingress And Gateway

When a published service does not answer, the cause sits at one of a few levels: the controller is not running, the Gateway was not programmed, the route was not accepted, the backend does not resolve, or the traffic reaches Envoy and is dropped. A good fix starts by finding the level, and the cluster tells you where to look.

Keep one sentence in mind for this module: **read the status conditions from the top down (GatewayClass, Gateway, route), then the generated Service, then Envoy and Hubble, and stop at the first level that is not healthy.** You will break a route on purpose, read what the status says, and repair it.

The module has four parts. **Read The Status Conditions** works from the GatewayClass to the route. **Check The Controller And Its Prerequisites** covers the Helm values, the CRDs and the generated Service. **Look Inside Envoy** reads the proxy configuration and logs. **Follow The Request With Hubble And A Fault Checklist** traces a request and ends with a list of faults and their signs.

## Learning objectives

After this module you can:

- Read `Accepted`, `Programmed` and `ResolvedRefs` conditions and their reasons.
- Check that the Cilium Gateway controller has its prerequisites.
- Find the Service and the Envoy configuration Cilium created for a Gateway.
- Read the Envoy logs and Hubble flows of a failing request.
- Match a symptom to its likely fault.

## Before you start

You need the Gateway API objects from the previous modules: `Gateway`, listener and `HTTPRoute`, and the commands `kubectl get`, `kubectl describe` and `kubectl logs`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement and the Gateway API controller. The `GatewayClass` is named `cilium`.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

No `Gateway` exists yet. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
