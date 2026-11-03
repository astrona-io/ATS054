# Overview: Gateway Listeners, TLS And Route Types (Playground)

This is a playground, not a lab. It starts a cluster with Cilium and the example workloads, and then waits. There is no task, no `astrona submit` and no pass or fail. Create resources, break them, run `astrona destroy`, and start over.

## What is in the box

- A `kind` cluster with one control-plane node and one worker node. `kubectl` already points at it.
- Cilium with kube-proxy replacement, the Ingress controller in `dedicated` mode and the Gateway API controller. The Gateway API CRDs are installed. The IngressClass and the GatewayClass are both named `cilium`.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` | podinfo, Service port 80 |
  | `starfleet` | `probe` | go-httpbin, Service port 80 |
  | `starfleet` | `shuttle` | A pod with `curl` to send test requests |
  | `outpost` | `drifter` | A pod with `curl` in another namespace |

- No Ingress, Gateway or HTTPRoute exists yet. A kind cluster has no load balancer, so the generated Services never get an external address. Use the node address and the node port.

## Practice tasks

- Create a Gateway with an HTTP listener on port 80 and read `attachedRoutes` in the listener status before and after you create an HTTPRoute.
- Make a self-signed certificate with `openssl`, create a TLS Secret and add an HTTPS listener with `tls.mode: Terminate`. Send a request with `curl --resolve`.
- Put the Secret in the namespace `outpost`, reference it from a Gateway in `starfleet`, and read the `ResolvedRefs` condition. Then add a `ReferenceGrant`.
- Restrict a listener with `allowedRoutes.kinds` and see what the status says about a route of another kind.
- Check which Gateway API route CRDs are installed with `kubectl get crd`.
