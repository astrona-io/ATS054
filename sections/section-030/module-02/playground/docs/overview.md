# Overview: Migrate From Ingress To Gateway API (Playground)

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

Use them like this: `entry starfleet cilium-gateway-fleet`, then `req fleet.example.com /`.

## Practice tasks

- Create an Ingress with two paths and a TLS section, and write the Gateway and HTTPRoute that match it.
- Run both entry points at once and compare the Services `cilium-ingress-<name>` and `cilium-gateway-<name>`.
- Test the Gateway with a `Host` header before any DNS change.
- Try `ingress2gateway print` on an Ingress file if the tool is installed.
- Replace a `force-ssl-redirect` annotation with a `RequestRedirect` filter.
- Delete the Ingress and check that the Gateway still answers.
