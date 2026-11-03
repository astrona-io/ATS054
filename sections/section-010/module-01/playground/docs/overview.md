# Overview: Route External Traffic With Cilium Ingress And Gateway API (Playground)

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

## Helper

Paste this once in each new terminal. `entry` takes the name of a Service in `starfleet` and sets `NODE_IP` and `NODE_PORT` for it. `req` sends a request from `shuttle` with a chosen `Host` header.

```sh
entry() {
  NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  NODE_PORT=$(kubectl -n starfleet get service "$1" -o jsonpath='{.spec.ports[0].nodePort}')
}
req() {
  local host="$1" path="$2"; shift 2
  kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H "Host: $host" "$@" "http://$NODE_IP:$NODE_PORT$path"
}
```

Use them like this: `entry cilium-ingress-scout`, then `req scout.example.com /`.

## Practice tasks

- Create an Ingress for the host `probe.example.com` that sends `/` to the Service `probe`. Find the Service and the `CiliumEnvoyConfig` that Cilium created.
- Add the annotation `ingress.cilium.io/loadbalancer-mode: shared` to an Ingress and find which Service now carries it.
- Create a Gateway on port 80 and an HTTPRoute with two rules: a header match for `probe` and a default for `scout`. Test both with `curl`.
- Send the same host to a route in `outpost` and read the `Accepted` condition. Then change `allowedRoutes` on the listener and read it again.
- Set a weight of 1 on `scout` and 1 on `probe` and count the status codes of thirty requests to `/uuid`.
