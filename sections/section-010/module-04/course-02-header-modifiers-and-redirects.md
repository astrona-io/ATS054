---
draft: true
---
# Header Modifiers And Redirects

Sometimes the backend must see a header that the client did not send, or the client must receive a header from the platform. Sometimes a request must not reach any backend, because the URL moved. The `filters` list of a rule handles both. This part changes headers in both directions and answers a request with a redirect.

## Where filters sit

A **filter** is a step that the Gateway applies to a request that matched a rule. Filters run before the request goes to the backend, in the order of the list, except the response filters, which run on the way back. This part uses `RequestHeaderModifier`, `ResponseHeaderModifier` and `RequestRedirect`.

## Change request headers

The `RequestHeaderModifier` filter has three lists: `set` replaces a header or creates it, `add` appends a value to a header, and `remove` deletes headers by name. Save this as `httproute-headers.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: headers
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
  hostnames:
    - headers.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      filters:
        - type: RequestHeaderModifier
          requestHeaderModifier:
            set:
              - name: x-fleet-via
                value: cilium-gateway
            add:
              - name: x-fleet-tag
                value: edge
            remove:
              - x-secret
        - type: ResponseHeaderModifier
          responseHeaderModifier:
            set:
              - name: x-served-by
                value: fleet
      backendRefs:
        - name: probe
          port: 80
```

The rule sets one request header, adds one, removes `x-secret` and sets one response header. Apply it:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f httproute-headers.yaml
```

Read the entry point and send a request to the path `/headers` of go-httpbin, with a header that the route must remove:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -i -H 'Host: headers.example.com' -H 'x-secret: 1' "http://$NODE_IP:$NODE_PORT/headers"
```

The endpoint `/headers` returns the request headers that go-httpbin received. The JSON lists `X-Fleet-Via` and `X-Fleet-Tag`, and it does not list `X-Secret`. The response headers printed by `-i` include `x-served-by: fleet`. This is the proof that a header modifier works: the backend itself reports the result.

## Redirect a request

The `RequestRedirect` filter answers the client with a redirect, so no backend is used. Its fields `scheme`, `hostname`, `port` and `path` say how the new URL differs from the old one, and `statusCode` is `301` (moved permanently) or `302` (found, a temporary move). Save this as `httproute-redirect.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: redirect
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
  hostnames:
    - old.example.com
  rules:
    - filters:
        - type: RequestRedirect
          requestRedirect:
            hostname: headers.example.com
            statusCode: 301
```

Apply it and look at the answer:

```sh
kubectl apply -f httproute-redirect.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -i -H 'Host: old.example.com' "http://$NODE_IP:$NODE_PORT/get"
```

The status line is `301`, and the `Location` header holds a URL with the host `headers.example.com`. The rule has no `backendRefs`, because the redirect is the whole answer. A redirect and a backend in the same rule is not allowed.

## Redirect to HTTPS

A common redirect changes only the scheme. A filter with `scheme: https` and `statusCode: 301` sends HTTP clients to the HTTPS URL on the same host. When you change the scheme without a `port`, the redirect uses the default port of the new scheme. State the port when the HTTPS listener is not on 443.

## Common pitfalls

> [!WARNING]
> A rule cannot hold a `RequestRedirect` filter and `backendRefs` at the same time. `set` replaces a header and `add` appends to it, so a request that already has the header sees two values after an `add`. Header names are not case sensitive but the echo in go-httpbin capitalises them. Use `301` only when the move is permanent, because browsers cache it.
