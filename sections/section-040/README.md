---
draft: true
exam_objectives:
- Encrypting Traffic in Transit with Cilium
---
# Encrypting Traffic in Transit with Cilium

This section explains how Cilium encrypts pod traffic between nodes with WireGuard or IPsec, what each mode covers and leaves open, and how mutual authentication with SPIFFE and SPIRE adds proof of identity.

## Learning Outcomes

- Explain transparent encryption and how it differs from TLS in the application.
- Describe the WireGuard device, keys and peers, and the traffic that default encryption does not cover.
- Build the IPsec key secret and describe a key rotation.
- Separate encryption, authentication and authorization.

## Learning Path

The section has one module, **Encrypting Traffic In Transit With Cilium**, with these parts in order:

1. Transparent Encryption With WireGuard
2. IPsec And Choosing An Encryption Mode
3. Mutual Authentication With SPIFFE And SPIRE

The module has an ungraded playground, a graded lab (**Turn On WireGuard Encryption**) and a summary. The section closes with a capstone lab (**Add Node-To-Node Encryption To WireGuard**) and a knowledge check. The labs are untested and checked statically only.
