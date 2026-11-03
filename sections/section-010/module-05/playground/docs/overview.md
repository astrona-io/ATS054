# Overview: Troubleshoot Cilium Ingress And Gateway (Playground)

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

- Break a route on purpose with a wrong `sectionName`, and read the `Accepted` reason.
- Point a backend at a port that does not exist and read `ResolvedRefs`.
- Run `kubectl get gatewayclass cilium` and read the `Accepted` condition.
- Find the Service `cilium-gateway-<name>` that Cilium creates and read its node port.
- Run `cilium status` in the agent pod and read the line for the Envoy proxy.
- Read the `cilium-envoy` logs while you send a request.
