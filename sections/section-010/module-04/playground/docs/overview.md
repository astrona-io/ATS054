# Overview: HTTPRoute Filters And Traffic Management (Playground)

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

- Create a Gateway and an HTTPRoute with a query parameter match and a method match, and test each with `curl`.
- Add a `RequestHeaderModifier` filter that sets, adds and removes headers, and read the result from `/headers` on `probe`.
- Add a `RequestRedirect` filter with `scheme: https` and with a `path` replacement, and read the `Location` header.
- Add a `URLRewrite` filter that replaces the host name, then one that replaces a prefix.
- Add a `RequestMirror` filter that copies requests to `probe`, and read the `probe` log.
- Split traffic 90 to 10 between `scout` and `probe` and count the replies of 40 requests.
