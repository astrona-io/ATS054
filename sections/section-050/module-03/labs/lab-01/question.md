# Question

Solve this question on: `terminal`

A team plans to move the namespaces of this cluster from a sidecar mesh to the Cilium node proxy. Before the migration they need an inventory. The ConfigMap `migration-inventory` in the namespace `starfleet` has four keys that all say `TODO`. Read the facts from the cluster and write them into the ConfigMap. Change the values only: keep the name of the ConfigMap and its four keys.

1. `injected-namespaces`: the names of the namespaces with the label `sidecar.example.io/inject=true`. Write one name, or names separated by spaces.
2. `sidecar-pods`: the number of pods in `starfleet` and `outpost` that have a container named `proxy`.
3. `l7-policies`: the number of `CiliumNetworkPolicy` objects in `starfleet` and `outpost` that have an HTTP rule (`rules.http`).
4. `envoy-ready`: `yes` if every pod of the DaemonSet `cilium-envoy` is ready, otherwise `no`.

`kubectl` already points at the cluster. Do not change any other object. The migration itself is not part of this lab.
