---
draft: true
---
# Node Encryption And Strict Mode

The default WireGuard setting protects pod traffic between nodes. It leaves two gaps that you should know before you tell anyone the cluster is encrypted.

## What the default leaves open

- **Traffic of the node itself.** Packets from a node's own processes, such as the kubelet or host-networked pods, are not pod traffic and are not encrypted by default.
- **Traffic while encryption is not ready.** After an agent restart, or when a peer is not yet known, the agent has no key for the destination. In the default mode the packet is sent without encryption, so the application keeps working but the data is open for a short time.

## Node encryption

The Helm value `encryption.nodeEncryption=true` (the key `encrypt-node` in `cilium-config`) extends encryption to traffic that starts at a node. It costs CPU and it excludes some traffic that is needed for the cluster to work, such as the traffic of control plane nodes in some setups, so test it first. In a lab you can set the key in the ConfigMap and restart the DaemonSet, but in a real cluster change the Helm values so that the next upgrade does not undo it.

## Strict mode

Strict mode closes the second gap. With `encryption.strictMode.enabled=true` Cilium drops traffic from pods in a CIDR that you give (`encryption.strictMode.cidr`) when it should be encrypted but is not. The packet is lost instead of sent in the clear. The cost is that traffic fails while a peer is not ready, which is what a strict policy wants.

You choose the CIDR carefully: it must cover the pod CIDRs of the nodes and not cover addresses that cannot be encrypted. A wrong CIDR drops traffic that was fine.

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get configmap cilium-config -o yaml | grep -i 'encrypt\|strict'
```

The keys show which of these settings the agents read in your cluster.

## Choosing

| Need | Setting |
| --- | --- |
| Encrypt traffic between pods on different nodes | `encryption.enabled=true` with WireGuard |
| Also encrypt traffic that starts at a node | Add `encryption.nodeEncryption=true` |
| Never send pod traffic in the clear | Add strict mode with the right CIDR |

## Common pitfalls

> [!WARNING]
> Do not enable strict mode in production on a first try. Enable it in a cluster that is a copy, watch the drops with Hubble during an agent restart, and then roll it out. Settings that exist in your Cilium version can differ from this text, so read the Helm values of the chart you install.
