# Question

Solve this question on: `terminal`

The platform team wants proof that this cluster runs a sidecarless mesh architecture. The ConfigMap `architecture-report` in the namespace `starfleet` has four keys that all say `TODO`. Read the facts from the cluster and write them into the ConfigMap. Change the values only: keep the name of the ConfigMap and its four keys.

1. `agent-pods`: the number of Cilium agent pods (label `k8s-app=cilium`) in `kube-system`.
2. `envoy-pods`: the number of `cilium-envoy` pods (label `k8s-app=cilium-envoy`) in `kube-system`.
3. `max-containers`: the largest number of containers in one pod of the namespaces `starfleet` and `outpost`.
4. `sidecar-webhooks`: the number of mutating webhook configurations whose name contains `istio` or `linkerd`.

`kubectl` already points at the cluster. Do not change any other object.
