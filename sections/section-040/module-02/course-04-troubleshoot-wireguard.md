---
draft: true
---
# Troubleshoot WireGuard

When encryption does not work, the cause is on a short list. Follow the checks in this order, and stop at the first one that fails.

## 1. Is the setting applied?

Read `enable-wireguard` in `cilium-config`, then read the status line of every agent. A ConfigMap that says `true` with a status line that says `Disabled` means the agent was not restarted.

## 2. Does the kernel support it?

WireGuard needs kernel support (built in from Linux 5.6, or a module before that). Read the agent log:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system logs ds/cilium -c cilium-agent | grep -i wireguard | tail
```

A message that the device cannot be created points at the kernel of the host. In kind, the host is the machine that runs the container engine, so the fix is there, not in the cluster.

## 3. Does every node publish a key?

Read the annotation `network.cilium.io/wg-pub-key` of every node. A node without it has no WireGuard device.

## 4. Are the peers there and are handshakes recent?

`cilium-dbg encrypt status` lists each peer. A peer that is missing or that shows no recent handshake points at the network: UDP 51871 is blocked, or the node address that the peer uses is not reachable.

## 5. Does the traffic use the device?

Compare the counters of `cilium_wg0` before and after a request across nodes. If they stay at zero, the traffic takes another path: a rule excludes it, or the destination is on the same node.

## 6. Is the packet size the problem?

Large responses that hang while small ones work are an MTU problem. See the previous part.

## What the flows show

Hubble records whether a flow was encrypted. In the JSON output a flow has an `encrypted` field in its IP data, so you can filter with `jq` for flows that you expect to be encrypted:

```sh
agent hubble observe -o json --last 20 | grep -c '"encrypted":true'
```

## Common pitfalls

> [!WARNING]
> Do not delete the `cilium_wg0` device or the node annotations to "reset" encryption. The agent recreates them, but peers can lose their key for a while and traffic can drop. Restart the agent instead and read the log.
