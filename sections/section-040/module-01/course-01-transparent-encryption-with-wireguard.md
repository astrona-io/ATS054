---
draft: true
---
# Transparent Encryption With WireGuard

Traffic between two pods on different nodes leaves the first node and crosses the physical network as clear packets, unless something encrypts it. Cilium can encrypt this traffic in the kernel without any change to the applications. This part explains what transparent encryption is, how Cilium uses WireGuard to provide it, how to turn it on and check it, and which traffic it does not cover.

## What transparent encryption means

**Encryption in transit** protects data while it moves over a network, so that a device on the path cannot read or change it. **Transparent encryption** means that the application does not take part. The application sends plain TCP, and the node encrypts the packets on the way out and decrypts them on the way in. The application needs no certificate, no library and no code change.

This differs from TLS between applications. With TLS, each application holds a certificate, and the encryption goes from one process to another. With transparent encryption, the encryption goes from one node to another. A process on a node can still read the plain traffic of every pod on that node.

## How WireGuard works in Cilium

**WireGuard** is a VPN (virtual private network) protocol that is part of the Linux kernel since version 5.6. It runs over UDP and uses public-key cryptography. Each node has a private key and a public key, and a node sends encrypted packets only to peers whose public keys it knows.

When you enable WireGuard, each Cilium agent creates a network device called `cilium_wg0` on its node. The agent generates a key pair, and it publishes the public key as an annotation on the Kubernetes Node object. Every agent reads the annotations of the other nodes, and it adds each node as a WireGuard peer. For each peer, the allowed IP addresses are the pod IP addresses of that node. An eBPF program sends the traffic for a remote pod through `cilium_wg0`, and the kernel encrypts it and sends it to the peer over UDP port 51871.

There are no certificates to manage. The pod IP addresses of a node decide which peer receives a packet. Nodes must reach each other on UDP port 51871, so a firewall between nodes needs a rule for it.

## Enable WireGuard

The Helm values are `encryption.enabled=true` and `encryption.type=wireguard`. The playground cluster was installed with these values. Check that the kernel of your nodes has WireGuard and that the agents report it:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get ds cilium
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep Encryption
```

The line that starts with `Encryption` names WireGuard and the device `cilium_wg0`, and it gives the number of peers. In a cluster with two nodes, each agent has one peer, which is the number of nodes minus one.

Look at the public key that the agent published. The annotation name starts with `network.cilium.io`:

```sh
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.annotations}{"\n"}{end}'
```

The annotations of each node include the public key of its WireGuard device. The private key stays on the node.

## Test that pod traffic still works

The encryption is invisible to applications, so a request between pods on different nodes works as before. Send a request from `shuttle` to `scout`:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n starfleet get pods -o wide
```

The first command prints `200`. The second shows on which nodes the pods run. A request between two pods on the same node is not encrypted, because it never leaves the node. A request between pods on different nodes goes through `cilium_wg0`.

## Check the peers and the keys

The status line gives a count. For the detail, ask the agent for its debug information. The output is JSON, and the part under `encryption` lists each peer with its public key and its allowed IP addresses:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg debuginfo --output json
```

Each peer public key must match the public key that the remote node published, and the allowed IP addresses of a peer must be the pod IP addresses of that node. A peer with a wrong key or with missing allowed addresses explains packets that are dropped between two specific nodes.

To prove that packets leave encrypted, capture traffic on the device `cilium_wg0` with `tcpdump -n -i cilium_wg0` inside the agent pod. The tool is not part of the agent image by default, so install it first. The packets on `cilium_wg0` are the clear packets before encryption, and a capture on the physical interface shows UDP packets to port 51871 whose content is not readable.

## What WireGuard covers and what it does not

By default, Cilium encrypts only the traffic between pods that Cilium manages on different nodes. Traffic from a pod to a node, from a node to a pod and from one node to another is clear. A beta option, `encryption.nodeEncryption=true`, adds node-to-node, pod-to-node and node-to-pod traffic. The nodes that have the label `node-role.kubernetes.io/control-plane` are excluded by default, so that workers can always reach the API server to update their keys.

These cases are also not encrypted:

- Traffic between two pods on the same node.
- Load balancer traffic that an intermediate node redirects with XDP acceleration or with direct server return in non-Geneve mode.
- Replies of the egress gateway when XDP acceleration is on.

With a tunnel routing mode, pod traffic is encapsulated twice, so the effective MTU (maximum transmission unit, the largest packet size) is smaller. Packets can be dropped while the WireGuard device is being configured, which shows as short connection problems after you enable it.

## Enable WireGuard on a running cluster

The Helm values are stored in the ConfigMap `cilium-config` in `kube-system`. The key `enable-wireguard` set to `"true"` has the same effect as the Helm values, and the agents read it at start. You change the ConfigMap, and then you restart the agents.

```sh
kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.enable-wireguard}{"\n"}'
```

The value is `true` in the playground. On a cluster without encryption, you set the value and run `kubectl -n kube-system rollout restart ds/cilium`. Production clusters normally change Helm values with `helm upgrade` so the change is kept in the release.

## What you know now

Transparent encryption protects pod traffic between nodes with no change in the application. Cilium uses WireGuard: one device per node, one key pair per node, the public key in a Node annotation, and the pod IP addresses of each peer as allowed addresses. The open question is what to do on kernels or policies where WireGuard is not the right fit.

## Common pitfalls

> [!WARNING]
> - UDP port 51871 must be open between all nodes. A blocked port shows as a peer that never completes a handshake.
> - WireGuard needs kernel support. On a kernel older than 5.6, the module must be installed separately.
> - Traffic between pods on the same node is not encrypted by design.
> - Encryption does not authenticate workloads. A pod can still send a request to any pod that policy allows.
