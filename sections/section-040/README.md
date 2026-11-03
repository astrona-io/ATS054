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
- Verify WireGuard with the status line, peers and counters, and plan ports, MTU and strict mode.
- Rotate an IPsec key line and read the kernel state.
- Require mutual authentication in a policy and read the authentication table.

## Learning Path

The section has four modules. The first, **Encrypting Traffic In Transit With Cilium**, has these parts in order:

1. Transparent Encryption With WireGuard
2. IPsec And Choosing An Encryption Mode
3. Mutual Authentication With SPIFFE And SPIRE

The second, **Operate WireGuard Encryption**, has these parts in order:

1. Verify That WireGuard Is Active
2. Node Encryption And Strict Mode
3. Ports, MTU And Overhead
4. Troubleshoot WireGuard

The third, **Operate IPsec Encryption**, has these parts in order:

1. How Cilium Uses IPsec
2. The Key Secret
3. Rotate The Keys
4. Read The State And Choose A Mode

The fourth, **Mutual Authentication In Practice**, has these parts in order:

1. The SPIRE Components
2. Require Authentication In A Policy
3. Observe And Verify
4. Limits And Troubleshooting

Each module has an ungraded playground, a graded lab (**Turn On WireGuard Encryption**, **Record The WireGuard Settings Of A Cluster**, **Rotate The IPsec Key Secret** and **Require Mutual Authentication For A Service**) and a summary. The section closes with a capstone lab (**Add Node-To-Node Encryption To WireGuard**) and a knowledge check. The labs are untested and checked statically only.
