---
draft: true
---
# Summary

Transparent encryption protects pod traffic between nodes without any change in the application. The node encrypts packets on the way out and decrypts them on the way in. This differs from TLS inside the application, where each process holds a certificate. By default Cilium encrypts only the traffic between pods that it manages on different nodes. Traffic between pods on the same node stays clear, and so does node traffic unless node encryption is enabled.

With WireGuard, each Cilium agent creates the device `cilium_wg0`, generates a key pair and publishes the public key on its Node object. Every agent adds the other nodes as peers, with the pod IP addresses of each node as the allowed addresses, and the kernel sends encrypted packets over UDP port 51871. WireGuard needs Linux kernel 5.6 or later, or an extra kernel module. The agents manage the keys, so there is nothing to rotate by hand.

With IPsec, the kernel applies keys through XFRM security policies and security associations. The keys come from the Secret `cilium-ipsec-keys` in `kube-system`. Its value holds a key identifier, an algorithm, a hexadecimal key and a key size, and a plus sign after the identifier turns on per-tunnel keys. You rotate by patching the Secret with the identifier increased by one. IPsec does not support host policies, it does not support chaining, and it decrypts with one CPU core for each tunnel.

Encryption, authentication and authorization are three controls. Encryption hides content, authentication proves identity, and authorization decides what an identity may do. Mutual authentication uses SPIFFE identities and short-lived certificates that a SPIRE server issues. The Cilium agents run the handshake on behalf of the pods, and a policy asks for it with `authentication.mode: required`. The feature is beta, works inside one cluster and does not encrypt traffic by itself.

- Same-node pod traffic is not encrypted by design.
- WireGuard uses UDP port 51871 between all nodes.
- The IPsec key identifier goes from 1 to 15 and increases at each rotation.
- Authentication does not encrypt, and encryption does not authenticate.
- Never print or share a key.

<!-- astrona:playground:destroy -->
