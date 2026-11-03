# Question

Solve this question on: `terminal`

Cilium in this cluster encrypts pod-to-pod traffic between nodes with WireGuard. The security team found that traffic between the nodes themselves, and between pods and nodes, is still clear. The release was installed with Helm, in the namespace `kube-system`, with the release name `cilium` and the chart version `1.20.2` from the repository `https://helm.cilium.io/`.

Turn on node-to-node encryption in the Helm release:

1. Set the value `encryption.nodeEncryption` to `true` with `helm upgrade`. Keep every other value of the release.
2. Wait for the Cilium agents to roll out. Every agent must still report WireGuard in `cilium-dbg status`.
3. The change must live in the Helm release and in the ConfigMap `cilium-config`. A direct patch of the ConfigMap alone does not count.
4. Pod traffic must keep working. The `shuttle` pod and the `drifter` pod must still reach `scout`, and `shuttle` must still reach `probe`.

Send test requests with `kubectl exec` from `shuttle` in `starfleet` and `drifter` in `outpost`, which both have `curl`. `kubectl` already points at the cluster.
