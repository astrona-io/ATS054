# Overview: Cilium Ingress In Depth (Playground)

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

- Create two Ingress resources in dedicated mode and list the Services that Cilium creates. Then set the annotation `ingress.cilium.io/loadbalancer-mode: shared` on one of them and find which Service carries it.
- Create an Ingress with the path types `Exact`, `Prefix` and `ImplementationSpecific` for the Service `probe`, and test which request paths each one matches.
- Make a self-signed certificate with `openssl`, store it with `kubectl create secret tls`, add a `tls` entry to an Ingress and send an HTTPS request with `curl --resolve`.
- Read the status code of a plain HTTP request to a host that has a `tls` entry, then add the annotation `ingress.cilium.io/force-ssl-redirect: "false"` and read it again.
- Set the annotation `ingress.cilium.io/service-type: NodePort` on an Ingress and read the type of the Service that Cilium builds.
