# Overview: Gateway API Compared With Ingress (Playground)

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

- No Ingress, Gateway or route exists yet. A kind cluster has no load balancer, so the generated Services never get an external address. Use the node address and the node port.

## Helper

Paste this once in each new terminal. `entry` takes the namespace and the name of a generated Service and sets `NODE_IP` and `NODE_PORT`. `req` sends a request from `shuttle` with a chosen `Host` header.

```sh
entry() {
  NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  NODE_PORT=$(kubectl -n "$1" get service "$2" -o jsonpath='{.spec.ports[0].nodePort}')
}
req() {
  local host="$1" path="$2"; shift 2
  kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H "Host: $host" "$@" "http://$NODE_IP:$NODE_PORT$path"
}
```

Use them like this: `entry edge cilium-gateway-edge-gw`, then `req scout.example.com /`.

## Practice tasks

- Create a Gateway in `edge` with the default `allowedRoutes` and a route in `starfleet`. Read the `Accepted` condition, then change the listener to `from: All`.
- Create a second route in `outpost` and let only `outpost` attach, with a label selector.
- Point a route in `outpost` at the Service `probe` in `starfleet`. Read `ResolvedRefs`, then add a `ReferenceGrant` that names only `probe`.
- Write a route with a `RequestRedirect` filter and read the status code with `curl -i`.
- Create the same host as an Ingress and as an HTTPRoute and compare what Cilium creates for each.
