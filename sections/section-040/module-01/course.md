---
draft: true
---
# Encrypting Traffic In Transit With Cilium

Pods on different nodes talk over the physical network. Without protection, a device on that network can read or change the packets. Cilium can encrypt pod traffic between nodes in the kernel, and it can also prove which workload sits at the other end of a connection. This module explains the two encryption modes, WireGuard and IPsec, and the mutual authentication that uses SPIFFE and SPIRE, and it shows what each one covers and what it leaves open.

Keep one sentence in mind for this module: **transparent encryption protects the traffic between nodes with no change in the application, and mutual authentication proves the identity of the workload, so they answer different questions.** You will check WireGuard on a running cluster, build the key secret for IPsec, and ask for authentication in a policy.

The module has three parts. **Transparent Encryption With WireGuard** explains the device, the keys and the peers, and lists the traffic that WireGuard does not cover. **IPsec And Choosing An Encryption Mode** shows the key secret, key rotation and the XFRM state, and compares the two modes. **Mutual Authentication With SPIFFE And SPIRE** explains identities, the SPIRE components and the `authentication.mode` field of a policy.

## Learning objectives

After this module you can:

- Explain transparent encryption and how it differs from TLS in the application.
- Describe how WireGuard peers, keys and allowed IP addresses are set up by the Cilium agents.
- Name the traffic that default encryption does not cover and the option that adds node traffic.
- Build the IPsec key secret and describe how a key rotation works.
- Choose between WireGuard and IPsec from the kernel, the compliance rules and the limits.
- Separate encryption, authentication and authorization, and state what mutual authentication adds.

## Before you start

You need Kubernetes basics: namespaces, Secrets, ConfigMaps and `kubectl exec`. You should know what a certificate and a public key are at a basic level.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, WireGuard encryption, Hubble and mutual authentication with SPIRE. WireGuard also needs kernel support on the machine that runs the container engine.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 and pod port 9898 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 and pod port 8080 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A client pod with `curl` in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
