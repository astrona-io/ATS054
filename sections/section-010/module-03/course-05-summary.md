---
draft: true
---
# Summary

A Gateway holds listeners. Each listener has a name, a port, a protocol and an optional host name, and it limits the routes that may attach by namespace and by kind. A route attaches through `parentRefs`, and `sectionName` selects one listener. The route is accepted only when its host names overlap with the listener host name, and the listener counts accepted routes in `attachedRoutes`.

An `HTTPS` listener terminates TLS and takes its certificate from a Secret of type `kubernetes.io/tls` named in `certificateRefs`. The proxy picks the certificate from the SNI field of the handshake. A Secret in another namespace needs a `ReferenceGrant` in the namespace of the Secret that names the namespace of the Gateway. Without it, the listener reports `ResolvedRefs` as `False`.

A `TLS` listener in `Passthrough` mode forwards the encrypted stream and routes only by SNI host name with a `TLSRoute`, so the backend keeps the key and the Gateway cannot see paths or headers. A `GRPCRoute` matches gRPC service and method names. `TLSRoute` and `GRPCRoute` depend on the installed CRD channel and version.

Status tells where a fault is. Read the class, the Gateway, each listener and each route in that order, and fix the first condition that is `False`. A broken listener does not stop the other listeners of the Gateway.

- A listener is a port, a protocol and an optional host name.
- `sectionName` attaches a route to one listener.
- `Terminate` decrypts at the Gateway. `Passthrough` forwards encrypted traffic.
- `ReferenceGrant` lives in the namespace of the referenced object.
- `attachedRoutes: 0` means no route reached the listener.

<!-- astrona:playground:destroy -->
