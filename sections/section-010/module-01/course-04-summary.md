---
draft: true
---
# Summary

An Ingress or a Gateway only declares how HTTP requests are routed. The Cilium operator reads the resource, creates a Service of type `LoadBalancer` for it, and builds an Envoy configuration. The Envoy proxy on each node, which the `cilium-envoy` DaemonSet runs, matches each request and forwards it to the backend Service. eBPF programs on the node steer the packets to that proxy.

The Cilium Ingress controller needs `kubeProxyReplacement=true` and the L7 proxy, and it is enabled with `ingressController.enabled=true`. It owns Ingress resources with `ingressClassName: cilium`. In `dedicated` mode each Ingress gets its own Service and address, in `shared` mode all Ingress resources use the Service `cilium-ingress`, and the annotation `ingress.cilium.io/loadbalancer-mode` overrides the mode for one Ingress.

The Cilium Gateway API controller needs the Gateway API CRDs installed before the operator starts, `gatewayAPI.enabled=true` and `kubeProxyReplacement=true`. It owns the GatewayClass `cilium`. A `Gateway` defines listeners and decides which namespaces may attach routes through `allowedRoutes`. An `HTTPRoute` attaches to a Gateway with `parentRefs`, and it holds matches on path, header and host, plus backends with weights.

Status explains failures. An `HTTPRoute` reports `Accepted` and `ResolvedRefs` for each parent Gateway, and the reason names the wrong field. On a cluster without a cloud load balancer, the entry point is the node IP address and the node port of the generated Service.

- Ingress classes and Gateway classes select the controller: `cilium` for both.
- The Service names are `cilium-ingress-<ingress>` in dedicated mode and `cilium-gateway-<gateway>` for a Gateway.
- A `Host` header that no rule matches gets a `404` from Envoy.
- `weight` values are relative shares, not percentages.
- Read `status.parents[].conditions` before you read logs.

<!-- astrona:playground:destroy -->
