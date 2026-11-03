---
draft: true
---
# Map Ingress Fields To Gateway API

An Ingress has one object with everything in it. The Gateway API splits it across a Gateway and one or more routes. This part builds an Ingress and writes the equivalent objects, field by field.

## The Ingress to migrate

Save this as `ingress.yaml`. It has one host, two paths and a TLS section is left out for now:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fleet
  namespace: starfleet
spec:
  ingressClassName: cilium
  rules:
    - host: fleet.example.com
      http:
        paths:
          - path: /probe
            pathType: Prefix
            backend:
              service:
                name: probe
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scout
                port:
                  number: 80
```

<!-- astrona:playground:renew -->

```sh
kubectl apply -f ingress.yaml
```

## The translation table

| Ingress | Gateway API |
| --- | --- |
| `ingressClassName: cilium` | `gatewayClassName: cilium` on the Gateway |
| The controller creates the listener | A `listeners` entry (name, protocol, port) on the Gateway |
| `rules[].host` | `hostnames` of the HTTPRoute (and optionally `hostname` of the listener) |
| `paths[].path` and `pathType: Prefix` | `matches[].path` with type `PathPrefix` |
| `pathType: Exact` | `matches[].path` with type `Exact` |
| `pathType: ImplementationSpecific` | Depends on the controller; choose `PathPrefix` or `Exact` on purpose |
| `backend.service.name` and `port.number` | `backendRefs` with `name` and `port` |
| `defaultBackend` | A rule with no `matches` |
| `tls[].secretName` | `certificateRefs` of an HTTPS listener |

## Write the Gateway and the route

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
  hostnames:
    - fleet.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /probe
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

Apply it and compare the two entry points:

```sh
kubectl apply -f gateway.yaml
kubectl -n starfleet get ingress,gateway,httproute
kubectl -n starfleet get service
```

The listing shows the Services `cilium-ingress-fleet` for the Ingress and `cilium-gateway-fleet` for the Gateway. Each has its own address, so both work at the same time.

## What changes in the model

The Ingress is one object, so one team owns all of it. With the Gateway API the Gateway is the platform team's object and the route is the application team's. The migration is a chance to decide who owns what, and to set `allowedRoutes` on purpose.

## Common pitfalls

> [!WARNING]
> An Ingress path of type `Prefix` matches whole path elements, and so does `PathPrefix`, so the match is the same. Check `ImplementationSpecific` paths by hand, because the meaning depends on the controller. A route is only used when the Gateway accepts it, so read the status after you apply.
