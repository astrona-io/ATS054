---
draft: true
---
# Read The Status Conditions

Every Gateway API object reports its own health in `status.conditions`. A condition has a `type`, a `status` of `True`, `False` or `Unknown`, a short `reason` and a `message` in words. Reading them in the right order finds most faults without a log.

## Start at the top

The chain is GatewayClass, then Gateway, then listener, then route. A fault at a level hides the levels below it, so check in that order. First the class:

<!-- astrona:playground:renew -->

```sh
kubectl get gatewayclass cilium
```

The column `ACCEPTED` must be `True`. If it is `False`, the controller did not accept its class, and nothing below can work.

## Create a Gateway and a broken route

Save this as `broken.yaml`. The Gateway is fine. The route names a listener that does not exist:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: fleet
  namespace: starfleet
spec:
  gatewayClassName: cilium
  listeners:
    - name: web
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: fleet
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
      sectionName: websecure
  hostnames:
    - fleet.example.com
  rules:
    - backendRefs:
        - name: scout
          port: 80
```

```sh
kubectl apply -f broken.yaml
kubectl -n starfleet get gateway fleet
kubectl -n starfleet get httproute fleet -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
```

The Gateway shows `PROGRAMMED` as `True`, so the Gateway is healthy. The route prints `Accepted=False NoMatchingParent`, and `ResolvedRefs=True`. The reason names the fault: no listener called `websecure` exists on the parent.

## The three conditions

- `Accepted` says that the object is valid and can attach. For a route, the common reasons for `False` are `NoMatchingParent` (a wrong `sectionName`), `NoMatchingListenerHostname` (host names do not overlap), `NotAllowedByListeners` (namespace or kind not allowed) and `UnsupportedValue`.
- `Programmed` says that the data plane was configured. For a Gateway it means that Cilium created the Service and gave Envoy the configuration.
- `ResolvedRefs` says that every reference is valid. Reasons for `False` include `BackendNotFound`, `RefNotPermitted` (a missing `ReferenceGrant`) and `InvalidKind`.

Fix the route by changing `sectionName` to `web`, apply it, and read the conditions again. `Accepted` is now `True`.

## Use describe for the message

`kubectl describe httproute fleet -n starfleet` prints the same conditions with their messages, which say in words what is wrong. For a Gateway, `kubectl describe gateway` also lists `attachedRoutes` per listener: a count of `0` for a listener that should have a route means the route did not attach.

## Common pitfalls

> [!WARNING]
> A route status exists once per parent, so read all parents when a route has several. An empty `status` means no controller picked the object up, which usually means a wrong `gatewayClassName` or a controller that is not running. Check the `observedGeneration` of a condition: if it is older than the object `generation`, you are reading a status from before your last change.
