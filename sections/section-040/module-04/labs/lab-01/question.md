# Question

Solve this question on: `terminal`

Cilium runs in this cluster with mutual authentication: a SPIRE server and agents run in the namespace `cilium-spire`. The team wants every request from `shuttle` to `scout` to be authenticated. Write one `CiliumNetworkPolicy` in the namespace `starfleet` for the pods with the label `app: scout` that:

1. Accepts traffic only from the pods with the label `app: shuttle`, on the pod port 9898.
2. Requires mutual authentication for that traffic (`authentication.mode: required`).
3. Allows nothing else, so that `drifter` in the namespace `outpost` gets no answer.

`kubectl` already points at the cluster. Send test requests with `kubectl exec` from `shuttle` in `starfleet` and `drifter` in `outpost`, which both have `curl`.
