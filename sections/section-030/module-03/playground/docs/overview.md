# Overview: Gateway API Channels, Conformance And Extensions (Playground)

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

- List the CRDs of the group `gateway.networking.k8s.io` and their channel annotation.
- Read the `status` of the GatewayClass `cilium` and find its supported features if the field exists.
- Find which route kinds exist: `kubectl api-resources --api-group=gateway.networking.k8s.io`.
- Write a TLSRoute and a GRPCRoute and read their status.
- Read the field `parametersRef` of the GatewayClass.
- Try an `ExtensionRef` filter and read why the route is not accepted.
