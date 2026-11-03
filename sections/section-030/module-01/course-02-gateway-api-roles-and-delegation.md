---
draft: true
---
# Gateway API Roles And Delegation

The Gateway API separates the entry point from the routes, so that different teams own different objects. This part names the three roles and the resource each role owns, then shows the two rules that give a platform team control: which namespaces may attach routes to a Gateway, and which namespaces may point a route at a Service in another namespace.

## Three roles, three resources

The Gateway API names three roles. The **infrastructure provider** supplies the controller. The **cluster operator** runs the shared entry points. The **application developer** writes the routes for one application. Each role owns one kind of resource.

A **GatewayClass** is owned by the infrastructure provider. It names the controller, for example `io.cilium/gateway-controller`. A **Gateway** is owned by the cluster operator. It has `listeners`, and each listener has a name, a port, a protocol and an optional hostname. An **HTTPRoute** is owned by the application developer. It has hostnames, matching rules and backends, and it names its Gateway in `parentRefs`.

RBAC (role-based access control) then follows the roles. The cluster operator gets rights on `gateways` in the namespace `edge`. The developer gets rights on `httproutes` in the namespace of the application. A developer cannot change the port or the certificate of the listener, because those fields are in a Gateway that the developer cannot edit.

## Attachment is a two-way agreement

A route attaches to a Gateway only when both sides agree. The route names the Gateway in `parentRefs`. The Gateway lists the namespaces it accepts in `allowedRoutes` on each listener. The field `allowedRoutes.namespaces.from` has three values.

- `Same` accepts routes from the namespace of the Gateway only. This is the default.
- `All` accepts routes from every namespace.
- `Selector` accepts routes from the namespaces that match a label selector.

The controller writes the result in the status of the route. The condition `Accepted` is `True` or `False`, and the `reason` field says why. A route that the listener does not allow gets `Accepted=False` with the reason `NotAllowedByListeners`.

## Try it: a route that is not allowed

The Gateway lives in `edge`, and the route lives in `starfleet`. Save this as `gateway-edge.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: edge
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: edge-gw
  namespace: edge
spec:
  gatewayClassName: cilium
  listeners:
    - name: web
      protocol: HTTP
      port: 80
```

Apply it:

```sh
kubectl apply -f gateway-edge.yaml
```

Because the listener has no `allowedRoutes`, the default `Same` applies. Save this as `httproute-scout.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: scout
  namespace: starfleet
spec:
  parentRefs:
    - name: edge-gw
      namespace: edge
  hostnames:
    - scout.example.com
  rules:
    - backendRefs:
        - name: scout
          port: 80
```

Apply it:

```sh
kubectl apply -f httproute-scout.yaml
```

Then check the result:

```sh
kubectl -n starfleet get httproute scout -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
```

The `Accepted` condition is `False` with the reason `NotAllowedByListeners`. Cilium does not forward any request for this route, and the Gateway is unchanged.

## Delegate by label

The cluster operator decides which namespaces may attach. Change the listener to accept the namespaces that carry the label `access=gateway`. Save this as `gateway-edge-selector.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: edge-gw
  namespace: edge
spec:
  gatewayClassName: cilium
  listeners:
    - name: web
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              access: gateway
```

Apply it, then label the namespace of the route:

```sh
kubectl apply -f gateway-edge-selector.yaml
kubectl label namespace starfleet access=gateway
```

The route is now accepted. The label is the control: the platform team that owns namespace labels decides which teams may use the Gateway, and no developer edits the Gateway. Check the condition again:

```sh
kubectl -n starfleet get httproute scout -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
```

## Cross-namespace backends and ReferenceGrant

A route normally points to Services in its own namespace. A route can point to a Service in another namespace, but only if the owner of that Service agrees. The owner agrees with a **ReferenceGrant**, a resource in the namespace of the Service. It lists `from` (the kind and namespace of the referrer) and `to` (the kind and, optionally, the name of the target).

Without a grant, the controller sets the condition `ResolvedRefs` to `False` with the reason `RefNotPermitted`, and requests to that backend get an error response. A grant can name one Service, so it gives the minimum right. The grant protects the owner of a namespace from a team that guesses the name of a Service.

## What you know now

Routes and Gateways attach by agreement. The Gateway says which namespaces may attach, and a ReferenceGrant says which namespaces may reach a backend. Both checks show in the status of the route, so you debug with `kubectl get` and not with guesses. The open question is how much a route can express once it is attached.

## Common pitfalls

> [!WARNING]
> - `from: Same` is the default. A route in another namespace is rejected until you change the listener.
> - The status of the route updates only after the controller reconciles, so wait a few seconds after a change before you read it.
> - A ReferenceGrant lives in the namespace of the target Service, not in the namespace of the route.
> - `Accepted=True` does not mean the backend works. Check `ResolvedRefs` as well.
