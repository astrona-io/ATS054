# Question

Solve this question on: `terminal`

The pod `shuttle` in the namespace `starfleet` is a client that must talk only to the Service `scout` in the same namespace. Write one `CiliumNetworkPolicy` in `starfleet` that restricts the **egress** of `shuttle` and nothing else.

1. `shuttle` must still resolve names through DNS (the pods of `kube-dns` in `kube-system`).
2. `shuttle` must reach `scout` and nothing else. Remember that the Service `scout` listens on port 80 and forwards to the pod port 9898.
3. No other pod may be affected. The pod `drifter` in `outpost` must still reach `probe`.

`kubectl` already points at the cluster.
