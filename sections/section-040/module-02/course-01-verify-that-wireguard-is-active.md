---
draft: true
---
# Verify That WireGuard Is Active

A setting in a ConfigMap is a wish. The kernel and the agent tell you whether it happened. Check three places, from the quickest to the most detailed.

## The status line

Paste the helper once:

```sh
agent() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- "$@"; }
```

Then read the encryption line:

<!-- astrona:playground:renew -->

```sh
agent cilium-dbg status | grep '^Encryption'
```

The line looks like `Encryption: Wireguard [NodeEncryption: Disabled, cilium_wg0 (Pubkey: ..., Port: 51871, Peers: 1)]`. It has the mode, the node encryption state, the name of the device, the public key, the UDP port and the number of peers. On a cluster with two nodes each agent has one peer. If the line says `Disabled`, the agent runs without encryption, whatever the ConfigMap says. A restart is needed to apply a changed setting.

## The longer view

```sh
agent cilium-dbg encrypt status
agent ip -s link show cilium_wg0
```

The first command lists the interface, the public key and the peers with their endpoint and the time of the last handshake. The second shows the byte counters of the device. Send a request between two pods on different nodes and run it again: the counters must grow. Counters that stay at zero while pods talk across nodes mean the traffic does not use the device.

## The node annotations

Each node publishes its WireGuard public key in an annotation so that the other agents can add it as a peer:

```sh
kubectl get nodes -o custom-columns='NAME:.metadata.name,KEY:.metadata.annotations.network\.cilium\.io/wg-pub-key'
```

Every node must show a key. A node without a key has an agent that has not started WireGuard.

## Try it

Send a request from `shuttle` to `scout`, then read the counters of `cilium_wg0` on both agents. Only the node pair that carries the request shows more bytes. Pods on the same node never use the device.

## Common pitfalls

> [!WARNING]
> A request that works proves nothing about encryption: unencrypted traffic works too. Read the status line and the counters. Also read the status of every agent, not only one: a node whose agent did not restart still runs the old mode.
