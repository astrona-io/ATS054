---
draft: true
---
# Look Inside Envoy

When the status is healthy and the request still fails, the next place to look is the proxy. Cilium uses Envoy to handle Gateway and Ingress traffic. Depending on the install, Envoy runs inside the Cilium agent pod or as a separate DaemonSet named `cilium-envoy`. This part reads its configuration and logs.

## Find the Envoy configuration

Cilium turns each Gateway and its routes into a `CiliumEnvoyConfig` resource that the agent sends to Envoy. List them:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get ciliumenvoyconfig
kubectl -n starfleet get ciliumenvoyconfig cilium-gateway-fleet -o yaml | head -60
```

The configuration holds the listeners, the route table and the clusters (the backends) as Envoy sees them. You rarely edit it, because the controller owns it. You read it to check whether a route you wrote reached the proxy. If your route is `Accepted` but its host name or path is not in the configuration, the controller has not synced it yet.

## Read the Envoy logs

If Envoy runs as a DaemonSet, read its log:

```sh
kubectl -n kube-system get pods -l k8s-app=cilium-envoy
kubectl -n kube-system logs -l k8s-app=cilium-envoy --tail=30
```

If you do not find these pods, Envoy runs inside the agent, so read the log of the agent pod (`kubectl -n kube-system logs ds/cilium`). Look for lines about `upstream`, `no healthy upstream` and `route` when a request fails.

## Read the HTTP status

The status code a client receives points to a level:

- `404`: a request reached Envoy and no route matched. Check host names and paths.
- `503`: a route matched but the backend has no ready endpoints. Check the Service and its pods.
- `502`: Envoy could not talk to the backend. Check the port and the protocol.
- No answer at all: the request did not reach Envoy. Check the Service, the node port and network policy.

Send a request that does not match any route, and look at the answer:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -H 'Host: nothing.example.com' "http://$NODE_IP:$NODE_PORT/"
```

The status is `404`, which is the proof that the request reached Envoy and no route matched.

## Common pitfalls

> [!WARNING]
> The pod name and label of Envoy depend on the Cilium version and the Helm values, so check with `kubectl -n kube-system get pods` first. A `503` can also come from a Service with no ready pods, so check `kubectl get endpoints` before you read the Envoy log.
