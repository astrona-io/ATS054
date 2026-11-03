---
draft: true
---
# Matching, Splitting And Debugging Routes

A route that sends every request to one backend is the simplest case. Real routes choose a backend by path or header, and they send a share of the requests to a second version of a service. This part adds those rules to an `HTTPRoute`, splits traffic by weight, and reads the status conditions that Cilium writes when a route does not work.

## Match on path and header

An `HTTPRoute` has a list of rules. Each rule has `matches` and `backendRefs`. A request must satisfy one entry of `matches`, and every condition inside that entry must hold. Path types are `Exact`, `PathPrefix` and `RegularExpression`. Header matches compare the value of one request header.

Save this as `httproute-fleet.yaml`. It attaches to a `Gateway` named `fleet` in `starfleet` that listens on HTTP port 80 and allows routes from its own namespace. Create that Gateway first if it does not exist yet:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: fleet
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
  hostnames:
    - fleet.example.com
  rules:
    - matches:
        - headers:
            - name: x-fleet
              value: probe
      backendRefs:
        - name: probe
          port: 80
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: scout
          port: 80
```

The first rule sends requests that carry the header `x-fleet: probe` to `probe`. The second rule sends everything else to `scout`. When several rules match, Cilium follows the Gateway API precedence: the most specific match wins, so a header match beats a plain path prefix. Apply the route and test both cases:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f httproute-fleet.yaml
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: fleet.example.com' "http://$NODE_IP:$NODE_PORT/uuid" -o /dev/null -w '%{http_code}\n'
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: fleet.example.com' -H 'x-fleet: probe' "http://$NODE_IP:$NODE_PORT/uuid" -o /dev/null -w '%{http_code}\n'
```

The path `/uuid` exists on go-httpbin (`probe`) and not on podinfo (`scout`). The first request has no header, so it goes to `scout`, which answers `404`. The second request has the header, so it goes to `probe`, which answers `200`.

## Split traffic by weight

A `backendRef` can carry a `weight`. The proxy sends each backend a share of requests equal to its weight divided by the sum of all weights. Save this as `httproute-split.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: split
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
  hostnames:
    - split.example.com
  rules:
    - backendRefs:
        - name: scout
          port: 80
          weight: 90
        - name: probe
          port: 80
          weight: 10
```

Apply it and send twenty requests to the path `/uuid`. Count the status codes: about ninety percent of the requests go to `scout` and answer `404`, and about ten percent go to `probe` and answer `200`. The split is statistical, so a small sample can differ from the weights.

```sh
kubectl apply -f httproute-split.yaml
for i in $(seq 1 20); do kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -H 'Host: split.example.com' "http://$NODE_IP:$NODE_PORT/uuid"; done | sort | uniq -c
```

## Read the status of a route

Every controller reports the result of its work in the `status` of the resource. The `status.parents` list of an `HTTPRoute` has one entry for each Gateway the route tries to attach to. Each entry has these conditions:

- `Accepted`: the Gateway accepted the route. `False` has a reason such as `NotAllowedByListeners` (the listener does not allow this namespace) or `NoMatchingParent` (the parent name or listener is wrong).
- `ResolvedRefs`: every backend reference is valid. `False` has a reason such as `BackendNotFound` (the Service does not exist) or `RefNotPermitted`.

Read them for the route `fleet`:

```sh
kubectl -n starfleet get httproute fleet -o jsonpath='{range .status.parents[0].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
```

A healthy route prints `Accepted=True Accepted` and `ResolvedRefs=True ResolvedRefs`. Make a route fail on purpose to see a reason. Change the `parentRefs` name in a copy of the route to `fleet-typo`, apply it, and read the conditions again: `Accepted` becomes `False`. The Gateway also reports the number of attached routes in `status.listeners[].attachedRoutes`, and `kubectl describe httproute` shows the same conditions with a readable message.

## A debugging order

When a route does not work, check in this order. First, the `Accepted` condition: a `False` value means the route never attached. Second, `ResolvedRefs`: a `False` value means a backend Service or port is wrong. Third, the Service of the Gateway: the node port must exist. Fourth, the `Host` header and the path of the request against the `hostnames` and `matches` of the route. Each step names one component, and the first failing step is the cause.

## Common pitfalls

> [!WARNING]
> A wrong Service port in `backendRefs` gives a route that is accepted but returns errors, so read `ResolvedRefs` and test the backend Service directly. A `hostnames` entry that the request header does not match gives a `404`. Weights are relative values, not percentages: `weight: 1` and `weight: 1` split the traffic in half. A route with no `parentRefs` attaches to nothing.
