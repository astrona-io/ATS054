# Question

Solve this question on: `terminal`

The security team asks for a record of how WireGuard encryption runs in this cluster. Cilium is already installed with WireGuard. The ConfigMap `encryption-report` in the namespace `starfleet` has four keys that all say `TODO`. Read the facts from the Cilium agent and write them into the ConfigMap. Change the values only: keep the name of the ConfigMap and its four keys.

1. `interface`: the name of the WireGuard network device.
2. `port`: the UDP port the device listens on.
3. `peers`: the number of WireGuard peers of the agent.
4. `node-encryption`: `Enabled` or `Disabled`, as the agent reports node-to-node encryption.

You can read the agent with `kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status`. `kubectl` already points at the cluster. Do not change any other object.
