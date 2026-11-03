# Question

Solve this question on: `terminal`

The team removed an old sidecar mesh from the cluster, but the Deployment `probe` in the namespace `starfleet` still runs a leftover proxy container named `legacy-proxy` next to the container `probe`. Cilium already enforces a Layer 7 policy for `probe` on the node, with the CiliumNetworkPolicy `probe-l7`, so the leftover container is no longer needed.

Clean up the Deployment:

1. Remove the container `legacy-proxy` from the pod template of the Deployment `probe`. Keep the container `probe` unchanged.
2. Wait until the rollout finishes. Every pod with the label `app=probe` must be Ready and must have exactly one container.
3. Keep the policy `probe-l7` and the Cilium Envoy DaemonSet as they are. Layer 7 enforcement must keep working: `GET /get` from `shuttle` returns `200`, a `POST` from `shuttle` returns `403`, and `drifter` in `outpost` gets no reply.

Send test requests with `kubectl exec` from `shuttle` in `starfleet` and `drifter` in `outpost`, which both have `curl`. `kubectl` already points at the cluster.
