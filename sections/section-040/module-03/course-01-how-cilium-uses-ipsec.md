---
draft: true
---
# How Cilium Uses IPsec

IPsec is a set of protocols that protect IP packets. Cilium uses the **ESP** protocol (Encapsulating Security Payload), which encrypts and authenticates each packet, in the kernel's transport of the IPsec stack, called XFRM.

## Three kernel objects

The kernel keeps IPsec state in two tables, and the agent fills them:

- **States** (`ip xfrm state`) hold the keys. One state exists for each direction between a pair of nodes. Each has an **SPI** (security parameter index), a number that the receiver uses to find the right key.
- **Policies** (`ip xfrm policy`) say which packets must be protected: the traffic between the pod CIDRs of two nodes.
- The **key** itself comes from a Kubernetes Secret that you create.

When a pod sends a packet to a pod on another node, the kernel finds a matching policy, encrypts the packet with the key of the state and sends it as ESP. The receiving node finds the state by the SPI and decrypts.

## What the agent does

The agent reads the key Secret from a file in its pod, builds the states and the policies for every other node and watches the file for changes. A change of the file makes the agent add the new key. This is the mechanism behind rotation.

## What you must provide

- A Secret named `cilium-ipsec-keys` in `kube-system` (the name is a Helm value).
- The Helm values `encryption.enabled=true` and `encryption.type=ipsec`.
- A kernel with the IPsec modules and the algorithm that you chose.

## Look at it

<!-- astrona:playground:renew -->

```sh
agent() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- "$@"; }
agent ip xfrm state
agent ip xfrm policy
```

In the playground both lists are empty because IPsec is off. On a cluster with IPsec you would see one state per direction and per peer, and policies for the pod CIDRs.

## Common pitfalls

> [!WARNING]
> Do not delete XFRM states or policies by hand to fix a problem. The agent owns them, and a manual delete drops encrypted traffic until the agent rebuilds the state. Change the Secret or restart the agent instead.
