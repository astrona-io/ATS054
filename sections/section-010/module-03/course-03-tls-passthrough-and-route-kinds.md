---
draft: true
---
# TLS Passthrough And Route Kinds

Not every backend can sit behind a Gateway that decrypts traffic. A backend may hold its own certificate, may require the client certificate end to end, or may speak gRPC. The protocol of the listener and the kind of route decide how the Gateway treats such traffic. This part compares termination with passthrough and shows where `TLSRoute` and `GRPCRoute` fit.

## Terminate and Passthrough

A listener with the protocol `HTTPS` always terminates TLS, and HTTP routes can read the decrypted request. A listener with the protocol `TLS` has the mode `Terminate` or `Passthrough`. In `Passthrough` mode the Gateway does not decrypt anything. It reads only the SNI host name from the first message of the handshake and forwards the encrypted stream to the backend. The backend holds the certificate and the private key.

This table lists what each mode can see and do:

| Listener | TLS mode | Decrypts | Route kind | Can route by path or header |
| --- | --- | --- | --- | --- |
| `HTTPS` | `Terminate` | yes | `HTTPRoute`, `GRPCRoute` | yes |
| `TLS` | `Terminate` | yes | `TLSRoute` | no |
| `TLS` | `Passthrough` | no | `TLSRoute` | no, only by SNI host name |

In passthrough mode the Gateway cannot read paths, headers or methods, because the request is still encrypted. It also cannot apply Layer 7 policy or redirects.

## A TLS passthrough listener and TLSRoute

A `TLSRoute` selects the backend by the SNI host name. Save this as `gateway-passthrough.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: passthrough
  namespace: starfleet
spec:
  gatewayClassName: cilium
  listeners:
    - name: tls
      protocol: TLS
      port: 443
      hostname: vault.example.com
      tls:
        mode: Passthrough
      allowedRoutes:
        kinds:
          - kind: TLSRoute
        namespaces:
          from: Same
```

A route for it would be a `TLSRoute` with `hostnames: [vault.example.com]` and a `backendRefs` entry that points to a Service whose pods serve TLS themselves. `TLSRoute` belongs to the experimental channel of the Gateway API at the time of writing, and the API version depends on the CRD release that is installed. This playground installs the experimental channel. Check which route CRDs exist:

<!-- astrona:playground:renew -->

```sh
kubectl get crd | grep gateway.networking.k8s.io
```

The list shows `gateways`, `httproutes`, `gatewayclasses` and `referencegrants`, and in the experimental channel also route kinds such as `tlsroutes` and `grpcroutes`. Apply the Gateway above and read its status:

```sh
kubectl apply -f gateway-passthrough.yaml
kubectl -n starfleet get gateway passthrough -o jsonpath='{range .status.listeners[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
```

No `TLSRoute` is attached, so the listener has zero attached routes. The playground has no backend that serves TLS, so you do not send a request in this part.

## GRPCRoute

gRPC is an application protocol on HTTP/2. A **GRPCRoute** matches on the gRPC service and method name, which the Gateway reads from the request path, and not on a path you write by hand. It attaches to an `HTTPS` listener, or to an `HTTP` listener for gRPC without TLS. This pattern routes the method `GetUser` of the service `shuttle.UserService`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: users
  namespace: starfleet
spec:
  parentRefs:
    - name: secure
  hostnames:
    - scout.example.com
  rules:
    - matches:
        - method:
            service: shuttle.UserService
            method: GetUser
      backendRefs:
        - name: scout
          port: 80
```

The route is a pattern only. The playground has no gRPC backend, so do not apply it. The backend Service port also needs `appProtocol: kubernetes.io/h2c` when the connection from the Gateway to the backend is HTTP/2 without TLS.

## Which listener for which workload

Choose `HTTPS` with `Terminate` for ordinary web traffic that needs paths, headers, redirects or Layer 7 policy. Choose `TLS` with `Passthrough` when the backend must keep the private key or when the client certificate must reach the backend. The price of passthrough is that the Gateway no longer sees the request.

## Common pitfalls

> [!WARNING]
> An `HTTPRoute` cannot attach to a `TLS` listener, and a `TLSRoute` cannot attach to an `HTTP` listener. A passthrough listener needs a `hostname` so that the SNI can select the route. Experimental route kinds need the experimental CRDs: with the standard channel the kind does not exist and `kubectl apply` fails. Passthrough hides the request from Layer 7 rules and from Hubble HTTP flows.
