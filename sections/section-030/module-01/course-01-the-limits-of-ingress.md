---
draft: true
---
# The Limits Of Ingress

The Ingress resource was the first standard way to publish HTTP services from a Kubernetes cluster. It works for simple cases, and many clusters still use it. This part shows what one Ingress object holds, which needs it cannot express in its own fields, and how that pushes teams to annotations that only one controller understands.

## What an Ingress contains

An **Ingress** is a Kubernetes resource in the API group `networking.k8s.io`. It holds a list of rules. Each rule has an optional host and a list of paths, and each path points to a backend Service and port. It can also hold a `tls` list that names a Secret with a certificate. An **IngressClass** names the controller that must act on an Ingress, and an Ingress selects it with `ingressClassName`.

The Ingress API has two path types. `Exact` matches one path. `Prefix` matches a path and everything under it, split on the `/` character. There is no field for a header, a query parameter or an HTTP method. There is no field for a weight, a redirect or a rewrite. The API ends at host, path, TLS and backend.

## Create an Ingress in the playground

The playground has the Cilium Ingress controller enabled, so you can see what the object looks like at runtime. Save this as `ingress-scout.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scout
  namespace: starfleet
spec:
  ingressClassName: cilium
  rules:
    - host: scout.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scout
                port:
                  number: 80
```

Apply it:

```sh
kubectl apply -f ingress-scout.yaml
```

Then check the result:

```sh
kubectl -n starfleet get ingress scout
kubectl -n starfleet get service
```

The Cilium operator creates the Service `cilium-ingress-scout` for the Ingress. On a `kind` cluster no load balancer exists, so the Ingress never shows an external address. The Service still has a node port, and a client reaches the Ingress through the node IP address and that port.

## Three things the spec cannot say

Suppose the team of `scout` wants three things. Requests with the header `x-fleet: beta` go to a second version. Ten percent of all other requests go to the second version. Requests to `/old` get a redirect to `/new`. None of these has a field in the Ingress spec.

Each Ingress controller solves this with annotations. An **annotation** is a free-form key and value in the metadata of an object. The controller reads the keys it knows and ignores the others. The Cilium controller reads keys such as `ingress.cilium.io/loadbalancer-mode`. Another controller uses other keys for the same ideas, or no keys at all.

Annotations have three costs. A mistake in a key name is not an error, because the API server accepts any key. The behaviour moves with the controller, so an Ingress written for one controller does not behave the same under another. And annotations hold no status, so you cannot ask the API whether a key was understood.

List the annotations on your Ingress. An empty result means the controller added none:

```sh
kubectl -n starfleet get ingress scout -o jsonpath='{.metadata.annotations}{"\n"}'
```

## One object, several owners

An Ingress mixes the work of three roles. The infrastructure provider decides which controller exists. The cluster operator decides the listener: the address, the ports and the certificate. The application developer decides the host, the path and the backend. All three appear in one object, in one namespace.

This is a problem with permissions. Kubernetes RBAC (role-based access control) grants rights per resource kind and namespace. A developer who may edit the Ingress for the host `scout.example.com` may also edit its `tls` field, because the field is in the same object. The platform team cannot give the developer the path rules and keep the certificate for itself.

Two more limits come from the same design. The Ingress has no way to say which namespaces may use a host, so two teams can claim the same host and the controller picks one in a way that depends on the controller. And a path rule can only point to a Service in its own namespace, so a shared edge namespace cannot send requests to a backend in another namespace without a copy of the Service.

## Protocols beyond HTTP

The Ingress API describes HTTP and HTTPS. A TCP service, a gRPC service that needs gRPC-specific matching, or a TLS passthrough has no portable form. Controllers again add annotations, or custom resources that belong to one product. The reader who must publish a database port through the same entry point as the web services cannot do it with the Ingress API alone.

## What this means for the choice

Ingress still fits a cluster with one team, one controller and plain host and path routing. It has a small surface, and every controller supports it. The Gateway API exists for the cases in this part: split ownership, portable matching, weights, filters and more protocols.

Remove the Ingress when you finish:

```sh
kubectl -n starfleet delete ingress scout
```

## What you know now

You created an Ingress, saw that Cilium builds a Service and an Envoy configuration for it, and listed what its spec cannot express. The limits come from one object serving three roles, from a fixed set of fields, and from annotations that differ by controller. The open question is how a different resource model can separate the roles and still stay portable.

## Common pitfalls

> [!WARNING]
> - An annotation with a wrong key is accepted without any error and has no effect. Check the behaviour with a request.
> - An Ingress without `ingressClassName` is ignored by Cilium unless Cilium is the default Ingress controller.
> - Do not wait for an external address on `kind`. Use the node IP address and the node port of the generated Service.
> - A `Prefix` path matches whole path segments: `/old` matches `/old/x` and does not match `/older`.
