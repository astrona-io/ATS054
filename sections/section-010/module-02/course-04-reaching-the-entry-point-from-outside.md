---
draft: true
---
# Reaching The Entry Point From Outside

An Ingress that works from inside the cluster can still be unreachable for real clients, because the path from the internet to the node depends on the Service type, the traffic policy of the Service and the network the Envoy proxy listens on. This part covers the settings that decide how clients reach the entry point, and how a gRPC backend needs one extra setting on its Service.

## The Service decides how clients arrive

The entry point is a Kubernetes Service, so the normal Service rules apply. A Service of type `LoadBalancer` gets an address from a load balancer controller. On a cloud, the cloud controller does this. On bare metal, Cilium can do it with its own load balancer IP address management (LB IPAM), which hands out addresses from a pool that an administrator defines in a `CiliumLoadBalancerIPPool` resource. A Service of type `NodePort` opens the same port on every node, and clients connect to any node address and that port.

Check the type and the traffic policy of the entry point of the `scout` Ingress:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.type}{"\n"}{.spec.externalTrafficPolicy}{"\n"}'
```

The first line is the Service type. The second line is the external traffic policy, which is `Cluster` by default.

## External traffic policy

The field `externalTrafficPolicy` has two values. With `Cluster`, a node that receives a request may forward it to Envoy on another node, and that forward changes the source address of the request. With `Local`, a node sends the request only to Envoy on the same node and keeps the original client address, but a node with no ready Envoy drops the request. The Helm value `ingressController.service.externalTrafficPolicy` sets the policy for the shared Service, and you can change it on a dedicated Service with `kubectl patch`.

Use `Local` when the backend must see the real client address or when you want to avoid the extra hop. Make sure the load balancer health check removes nodes that cannot serve the request.

## Host network mode

Some clusters cannot use a Service of type `LoadBalancer` or a node port range. The Helm value `ingressController.hostNetwork.enabled=true` makes Envoy listen directly on a port of the node network, so clients connect to the node address and a normal port. The port comes from `ingressController.hostNetwork.sharedListenerPort`. With this mode a port conflict with another process on the node stops the listener, and you need to plan which port is free on every node. Host network mode works with the shared Ingress, so all Ingress resources then use that one port.

## gRPC backends

gRPC is an application protocol that uses HTTP/2. A client that speaks gRPC needs an HTTP/2 connection end to end, and a connection that downgrades to HTTP/1.1 fails. Envoy talks HTTP/2 to a backend only when the Service tells it to. Set `appProtocol: kubernetes.io/h2c` on the port of the backend Service for gRPC without TLS:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: shuttle-grpc
  namespace: starfleet
spec:
  selector:
    app: shuttle-grpc
  ports:
    - name: grpc
      port: 80
      targetPort: 9000
      appProtocol: kubernetes.io/h2c
```

The Service above is a pattern only. This playground has no gRPC backend, so you do not apply it. The Ingress that points at the Service looks like any other Ingress: host, path, `Prefix` and the Service name. The field `appProtocol` is the only gRPC specific setting. For a gRPC client over TLS, add a `tls` entry with a Secret, and the client connects to the HTTPS port.

## Which controller owns an Ingress

Cilium serves an Ingress only when its class matches. The Helm value `ingressController.default=true` makes Cilium the owner of Ingress resources that have no class at all, which is useful when old manifests omit `ingressClassName`. Leave it off when another controller runs in the same cluster, because two controllers would answer the same Ingress.

Confirm the class and the controller name:

```sh
kubectl get ingressclass cilium -o jsonpath='{.spec.controller}{"\n"}'
```

The controller name is `cilium.io/ingress-controller`.

## Clean up

Delete the Ingress resources of this module so the playground returns to a clean state:

```sh
kubectl -n starfleet delete ingress scout probe-paths scout-tls --ignore-not-found
kubectl -n starfleet delete secret scout-tls --ignore-not-found
```

You now know how the entry point is built, how it matches requests, how it encrypts them and how clients reach it.

## Common pitfalls

> [!WARNING]
> `externalTrafficPolicy: Local` drops requests that reach a node without a ready Envoy proxy. A gRPC backend without `appProtocol: kubernetes.io/h2c` fails even though the Service exists. Host network mode needs a free port on every node. Setting `ingressController.default=true` next to another Ingress controller makes two controllers answer one Ingress.
