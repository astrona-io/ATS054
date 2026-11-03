# Question

Solve this question on: `terminal`

The platform team wants to know what Gateway API this cluster has before it writes routes. The ConfigMap `gateway-inventory` in the namespace `starfleet` has four keys that all say `TODO`. Read the facts from the cluster and write them into the ConfigMap. Change the values only: keep the name of the ConfigMap and its four keys.

1. `channel`: the release channel of the installed Gateway API CRDs (`standard` or `experimental`).
2. `bundle-version`: the version of the installed CRD bundle.
3. `class-accepted`: the status (`True` or `False`) of the `Accepted` condition of the GatewayClass `cilium`.
4. `has-tlsroute`: `yes` if the CRD `tlsroutes.gateway.networking.k8s.io` exists, otherwise `no`.

`kubectl` already points at the cluster. Do not change any other object.
