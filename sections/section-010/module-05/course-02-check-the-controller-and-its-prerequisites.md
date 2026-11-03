---
draft: true
---
# Check The Controller And Its Prerequisites

When the status is empty or the Gateway is not `Programmed`, the problem is often the controller and not your YAML. The Cilium Gateway controller is part of the Cilium operator and the agent, and it has prerequisites that must hold when Cilium starts.

## What the controller needs

The Cilium Gateway API support needs these things:

- The Gateway API CRDs must be installed **before** the Cilium operator starts. If you install them later, restart the operator so it notices them.
- Cilium must run with `gatewayAPI.enabled=true` in the Helm values.
- Kube-proxy replacement must be on, because the Gateway traffic is handled by Cilium eBPF and Envoy.
- A GatewayClass named `cilium` must exist. The operator creates it when the controller starts.

Check each of them:

<!-- astrona:playground:renew -->

```sh
kubectl get crd gateways.gateway.networking.k8s.io httproutes.gateway.networking.k8s.io
kubectl -n kube-system get configmap cilium-config -o yaml | grep -i -E 'enable-gateway-api|kube-proxy-replacement'
kubectl get gatewayclass
kubectl -n kube-system get pods -l io.cilium/app=operator
```

The first command lists the CRDs. The second shows the setting `enable-gateway-api` as `"true"`. The third lists the class `cilium`, and the fourth shows that the operator pod is running.

## Read the operator log

If the class is missing, read the operator log:

```sh
kubectl -n kube-system logs deploy/cilium-operator --tail=50 | grep -i gateway
```

A message that a CRD was not found tells you that the CRDs were installed after the operator started. Install them, then restart the operator with `kubectl -n kube-system rollout restart deploy/cilium-operator`.

## The generated Service

For each Gateway, Cilium creates a Service named `cilium-gateway-<gateway name>` in the namespace of the Gateway. It is the entry point:

```sh
kubectl -n starfleet get service cilium-gateway-fleet
```

The Service type is `LoadBalancer`. On a `kind` cluster no load balancer gives it an external address, so the `EXTERNAL-IP` stays `<pending>`, and you reach the Gateway through the node port instead. A pending address on a cloud cluster with a load balancer is a real fault, and it usually means the cloud controller or the address pool is missing.

If the Service does not exist, the Gateway was not accepted by the controller. Go back to the Gateway conditions.

## Common pitfalls

> [!WARNING]
> Installing the CRDs after Cilium is the most common prerequisite fault, and the symptom is a missing GatewayClass and no status at all. Do not edit the generated Service, because the controller owns it and will overwrite your change. A `<pending>` external address is normal on `kind`.
