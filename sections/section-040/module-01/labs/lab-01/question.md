# Question

Solve this question on: `terminal`

The security team requires that pod traffic between nodes is encrypted. Cilium runs in this cluster without encryption, and the cluster has one control-plane node and one worker node.

Turn on WireGuard transparent encryption:

1. Enable WireGuard in the configuration that the Cilium agents read, the ConfigMap `cilium-config` in `kube-system`.
2. Make every Cilium agent apply it, and wait until the DaemonSet `cilium` has rolled out. Each agent must report WireGuard in the encryption line of `cilium-dbg status`.
3. Pod traffic must keep working. The `shuttle` pod and the `drifter` pod must still reach `scout`, and `shuttle` must still reach `probe`.

You can run commands in an agent with `kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status`. Send test requests with `kubectl exec` from `shuttle` in `starfleet` and `drifter` in `outpost`, which both have `curl`. `kubectl` already points at the cluster.
