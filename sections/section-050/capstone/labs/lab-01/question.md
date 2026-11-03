# Question

Solve this question on: `terminal`

The platform team moves two services from a sidecar mesh to the Cilium node proxy. The mesh is already removed, but the Deployments `scout` and `probe` in the namespace `starfleet` still carry a leftover container named `mesh-proxy`. The sidecar used to enforce the access rules, and these rules are gone. Today any pod can send any request to both services.

Finish the migration:

1. Remove the container `mesh-proxy` from the pod template of both Deployments. Wait until both rollouts finish.
2. Enforce this rule for `scout` with a CiliumNetworkPolicy: only the pods of `shuttle` may call it, and only with the method `GET`. A `POST` from `shuttle` must get `403`, and `drifter` in `outpost` must get no reply.
3. Enforce this rule for `probe` with a CiliumNetworkPolicy: only the pods of `shuttle` may call it, and only with `GET /get`. `GET /uuid` and every `POST` from `shuttle` must get `403`, and `drifter` must get no reply.
4. Keep the Cilium Envoy DaemonSet as it is.

`scout` listens on the pod port 9898 and `probe` listens on the pod port 8080. A policy applies to the pod port, not to the Service port 80. Send test requests with `kubectl exec` from `shuttle` in `starfleet` and `drifter` in `outpost`, which both have `curl`. `kubectl` already points at the cluster.
