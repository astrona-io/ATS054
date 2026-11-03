---
draft: true
---
# IPsec And Choosing An Encryption Mode

Cilium has a second transparent encryption mode, IPsec, which is older than its WireGuard mode and runs on more kernels. The two modes protect the same traffic, and they differ in how they get keys, how you rotate them and what they limit. This part explains how IPsec works in Cilium, shows how its key secret is built, and gives the rules for choosing between the modes.

## How IPsec works in Cilium

**IPsec** (Internet Protocol Security) is a set of protocols that encrypts IP packets. Cilium uses the ESP protocol (Encapsulating Security Payload) in the Linux kernel. The kernel keeps its IPsec rules in the XFRM framework: a **security policy** says which traffic must be encrypted, and a **security association** holds the keys and the algorithm for one direction between two nodes.

The Cilium agent creates these XFRM objects for every remote node, and an eBPF program marks the packets that must be encrypted. With the recommended setting, each pair of nodes gets its own key, which the agents derive from the shared secret. This is the meaning of the `+` after the key number in the secret: it switches on per-tunnel keys. Global keys are insecure and were deprecated in Cilium 1.16.

The Helm values are `encryption.enabled=true` and `encryption.type=ipsec`. IPsec is the default type, so the second value can be left out. Cilium reads the key from a Kubernetes Secret.

## The key secret

The Secret is named `cilium-ipsec-keys` and lives in `kube-system`. It has one key, `keys`, and the value has four fields: the key identifier, the algorithm, the pre-shared key in hexadecimal, and the key size in bits. A valid value looks like `3+ rfc4106(gcm(aes)) <hexadecimal key> 128`. The identifier is a number from 1 to 15.

Practise the format with a Secret that Cilium does not use. The name below is not the name Cilium reads, so nothing changes in the cluster. The command builds a random key and stores it:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system create secret generic ipsec-demo --from-literal=keys="3+ rfc4106(gcm(aes)) $(dd if=/dev/urandom count=20 bs=1 2> /dev/null | xxd -p -c 64) 128"
kubectl -n kube-system get secret ipsec-demo -o jsonpath='{.data.keys}' | base64 -d | cut -d' ' -f1,2,4
```

The second command prints the identifier, the algorithm and the size, and it leaves out the key. Never print or paste the key itself. Delete the demo Secret when you are done:

```sh
kubectl -n kube-system delete secret ipsec-demo
```

## Rotate the key

Key rotation replaces the key without a break in traffic. You patch the Secret with a new value that has the identifier increased by one. The identifier is a number from 1 to 15, and after 15 it starts again at 1. Old and new keys exist together during the change, and the agents remove the old key after about five minutes by default. The agent option `ipsec-key-rotation-duration` makes this window longer.

Agents wait a random time before they load a new key, so that a large cluster does not send all requests to the API server at once. Do not rotate during a Cilium upgrade. All nodes must run the same version first. Rotation is also the fix for stale XFRM states after a disruption of the control plane.

## Check IPsec on a node

In a cluster that runs IPsec, ask the agent for the status:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg encrypt status
```

The output shows the mode, the interfaces on which Cilium decrypts, the keys in use, the highest sequence number and an error count. Expect two keys for each remote node and each IP family, and up to four during a rotation. An error count that is not zero means the kernel reported XFRM errors, so look at the node logs. To see the traffic, capture ESP packets on the physical interface with `tcpdump -n -i eth0 esp`. You see both the ESP packets and the inner packets on the same interface, which is normal.

## Settings around IPsec

Three more settings matter in a real cluster. The value `encryption.ipsec.interface` names the network interface that faces the other nodes. It is optional, and when it is not set, Cilium uses the interface of the default route. With direct routing, Cilium also needs the native routing CIDR (the address range that nodes reach without a tunnel), set with `ipv4NativeRoutingCIDR` in Helm. When the Layer 7 proxy is on, the DNS proxy must run in transparent mode with the agent option `dnsproxy-enable-transparent-mode=true`.

Each of these settings fixes a different failure. A wrong interface shows as traffic that is encrypted on the wrong device. A missing routing CIDR shows as pod traffic that leaves the node unencrypted or does not leave at all. A DNS proxy that is not transparent shows as DNS rules that break after you enable IPsec.

## Three failure cases

The first failure is a limit of throughput between two nodes. IPsec decrypts with one CPU core for each tunnel, so one busy pair of nodes can reach the limit of a core. WireGuard does not have this limit in the same form.

The second failure is a key rotation during an upgrade. Cilium does not support a rotation while nodes run different versions, so finish the upgrade on every node first and rotate afterwards. A growing error count in `cilium-dbg encrypt status` after a change is the signal to read the node logs.


The third failure is a policy that you expect to apply to the node itself. Host policies are not supported with IPsec, so a rule for the host firewall is not enforced.

## IPsec against WireGuard

| Question | WireGuard | IPsec |
| --- | --- | --- |
| Key source | Generated by each agent, public key in a Node annotation | A shared secret that you create and rotate |
| Kernel | Linux 5.6 or later, or an extra module | Works with the standard XFRM support |
| Rotation | Handled by the agents | You patch the secret |
| Layer 7 proxy | No special setting | The DNS proxy must run in transparent mode |
| Host policies | Supported | Not supported |
| Throughput limit | Not tied to one core | One CPU core for each tunnel |

IPsec is not supported when Cilium runs chained on top of another CNI plugin. WireGuard with chaining needs the value `cni.enableRouteMTUForCNIChaining=true`, so that encrypted pod traffic is not fragmented.

## A decision rule

Choose WireGuard when the kernels are 5.6 or later and you want the agents to manage keys. Choose IPsec when the compliance rules name IPsec, when a kernel cannot run WireGuard, or when the cloud provider requires it. Both modes encrypt only node-to-node traffic of Cilium-managed pods by default, and both leave same-node traffic clear.

## What you know now

IPsec keeps its keys in a Secret that you build and rotate, and the kernel applies them through XFRM. WireGuard keeps its keys on the nodes. Both are transparent to applications. The open question is what neither mode proves: who the workload at the other end is.

## Common pitfalls

> [!WARNING]
> - The key secret must exist in `kube-system` before you enable IPsec, because the agents read the keys from it.
> - Do not paste the key into a ticket, a chat or a file in a repository.
> - A key identifier must go up by one at each rotation. Reusing an old identifier breaks the transition.
> - IPsec stops at the node boundary. Pods on the same node talk in clear text.
