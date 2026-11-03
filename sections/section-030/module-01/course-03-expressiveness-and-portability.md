---
draft: true
---
# Expressiveness And Portability

The Gateway API does more than split roles. It moves matching, traffic splitting and request changes into the fields of the route, and it defines status and conformance, so that the same YAML behaves the same under different controllers. This part builds one route that uses a header match and a request filter, and then explains what portable means and where the limits are.

## What a route can say that an Ingress cannot

An **HTTPRoute** rule has `matches` and `backendRefs`, and it can have `filters`. Each match can combine a path, headers, query parameters and an HTTP method. A rule applies when all conditions of one match are true, and a rule has several matches that act as alternatives.

Each backend reference has a `weight`, so one rule can split traffic. A **filter** is a built-in action that the controller runs on the request or the response. The standard filters are `RequestHeaderModifier`, `ResponseHeaderModifier`, `RequestRedirect`, `URLRewrite` and `RequestMirror`. In an Ingress, each of these needs a controller-specific annotation, if the controller supports it at all.

Other route kinds exist next to HTTPRoute. A `GRPCRoute` matches gRPC services and methods. A `TLSRoute` and a `TCPRoute` route by TLS server name or by port for traffic that is not HTTP. Their maturity differs, and the support of a controller for each kind is listed by the controller, not assumed.

## Build a route with a match and a filter

Create a Gateway in the namespace of the application. The listener uses the default `from: Same`, so the route in the same namespace attaches. Save this as `gateway-fleet.yaml`:

<!-- astrona:playground:renew -->

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
```

Apply it:

```sh
kubectl apply -f gateway-fleet.yaml
```

The route sends requests with the header `x-team: probe` to `probe`, and adds a header on the way. All other requests go to `scout`. Save this as `httproute-fleet.yaml`:

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
            - name: x-team
              value: probe
      filters:
        - type: RequestHeaderModifier
          requestHeaderModifier:
            add:
              - name: x-fleet
                value: gateway
      backendRefs:
        - name: probe
          port: 80
    - backendRefs:
        - name: scout
          port: 80
```

Apply it:

```sh
kubectl apply -f httproute-fleet.yaml
```

The Cilium operator creates the Service `cilium-gateway-fleet` for the Gateway. Find the node address and the node port, and define a helper that sends a request from the `shuttle` pod:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
send_request() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: fleet.example.com' "$@" "http://$NODE_IP:$NODE_PORT/headers"; }
```

Send a request without the header, and then with it:

```sh
send_request
send_request -H 'x-team: probe'
```

The first request goes to `scout`, so the reply comes from the `scout` application and not from `probe`. The second request goes to `probe`, which returns the request headers it received, and the list includes the header `X-Fleet` that the filter added. Envoy on the node ran the match and the filter, and no code in `scout` or `probe` changed.

## What portable means

The Gateway API is defined by the Kubernetes project as CRDs with a published specification. Every field has defined behaviour, and every controller must report status in the same conditions: `Accepted`, `Programmed` and `ResolvedRefs`. A route that is valid for one controller is valid for another, and a mistake shows in the same condition.

Portability has limits. The API has **channels**. The standard channel holds resources and fields that are stable. The experimental channel holds newer fields and kinds. A controller documents which features it supports, and the Gateway API project runs conformance tests per feature. A feature that a controller does not support is reported in the status, and it must not be assumed.

List the status of the Gateway and the class, which show the controller view:

```sh
kubectl -n starfleet get gateway fleet
kubectl get gatewayclass cilium -o jsonpath='{.status.conditions[*].type}{"\n"}'
```

## The limits of the comparison

The Gateway API does not remove the controller. Cilium still runs Envoy, and its limits stay: Layer 7 processing costs CPU on the node, and the Gateway needs a Service of its own for each Gateway. The Gateway API also adds more objects than an Ingress, so a simple site with one host and one path is shorter to write as an Ingress.

Remove what you created before you leave:

```sh
kubectl -n starfleet delete httproute fleet
kubectl -n starfleet delete gateway fleet
```

## What you know now

A route can match headers and methods, split traffic by weight and change requests with filters, and it reports its state in standard conditions. Portability comes from the specification, the channels and the conformance tests, and each controller documents what it supports. The decision between Ingress and Gateway API then rests on the number of teams and the features needed.

## Common pitfalls

> [!WARNING]
> - Within one match, all conditions must be true. Separate matches are alternatives.
> - A filter or field in the experimental channel may not be supported by your controller. Read the status of the route.
> - Header names in a match are not case-sensitive, and header values are exact unless the match type is `RegularExpression`.
> - A request to a path the backend does not serve returns the backend error, not a Gateway error.
