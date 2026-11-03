---
draft: true
---
# Ports, MTU And Overhead

WireGuard sends packets between nodes in UDP. The network between your nodes must carry them, and the extra bytes of the tunnel must fit in the packet size. Both are common causes of a cluster that is "encrypted but slow" or "encrypted but broken".

## The UDP port

Each node listens on UDP port 51871 by default (the status line shows it as `Port`). Firewalls, cloud security groups and host rules between the nodes must allow UDP 51871 in both directions. The handshake needs a packet from each side, so a rule that allows only one direction gives a peer that never completes the handshake.

## Overhead and MTU

WireGuard adds a header to each packet: 60 bytes over IPv4 and 80 bytes over IPv6. A pod that sends a packet of the full size of the network would make a packet that is too large. Cilium lowers the MTU of the pod interfaces by the overhead when encryption is on, so the packets fit. Check the result:

<!-- astrona:playground:renew -->

```sh
agent ip link show cilium_wg0
kubectl exec -n starfleet deploy/shuttle -- ip link show eth0
```

The device has a lower MTU than the physical interface, and the pod interface has the same MTU as the device or lower. If you set the MTU by hand in Helm (`MTU`), you must account for the overhead yourself.

Symptoms of a wrong MTU are:

- Small requests work and large responses hang.
- A `curl` that sends a big body stalls after the handshake.
- Counters of dropped fragments grow.

## Performance

Encryption uses CPU on every node. The kernel does the work, so the cost is lower than in a user-space proxy, but a node that moves a lot of traffic needs more CPU. Measure with your own traffic before you decide, and compare with the node CPU use before and after.

## Common pitfalls

> [!WARNING]
> Do not test an MTU change with a tiny request. Use a response of several kilobytes, such as `/bytes/20000` on `probe`, because a small response fits in any MTU.
