# Curriculum Coverage

Exam: Cilium Certified Associate (CCA). Domain: Service Mesh (16%).

The [official objectives](https://training.linuxfoundation.org/certification/cilium-certified-associate-cca/) were checked on 2026-10-11. Teaching structure is independently authored and does not add official requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Know How to use Ingress or Gateway API for Ingress Routing | 1 |
| 020 | Service Mesh Use Cases | 1 |
| 030 | Understand the Benefits of Gateway API over Ingress | 1 |
| 040 | Encrypting Traffic in Transit with Cilium | 1 |
| 050 | Sidecar-based versus Sidecarless Architectures | 1 |

## Hands-On Coverage

The course has 5 ungraded playgrounds, 5 module labs and 5 section capstones. Each section ends with a knowledge check, and a final domain quiz follows the last section. Labs are UNTESTED: they were checked with `astrona validate` and `bash -n` only, and live execution is pending.

| Section / module | Module | Module lab | Capstone |
| --- | --- | --- | --- |
| 010 / 01 | Route External Traffic With Cilium Ingress And Gateway API | Fix And Extend A Cilium Gateway Route | Publish Two Services With Cilium Ingress And Gateway API |
| 020 / 01 | Service Mesh Use Cases With Cilium | Apply Layer 7 Access Control With CiliumNetworkPolicy | Repair Layer 7 Policies Without A Sidecar |
| 030 / 01 | Gateway API Compared With Ingress | Delegate Gateway Access By Namespace Label | Share A Backend Across Namespaces With A Gateway |
| 040 / 01 | Encrypting Traffic In Transit With Cilium | Turn On WireGuard Encryption | Add Node-To-Node Encryption To WireGuard |
| 050 / 01 | Sidecar And Sidecarless Mesh Architectures | Remove A Leftover Sidecar Proxy | Migrate Two Services From Sidecars To The Node Proxy |

AUTHORING.yaml records measurable goals. Every objective keeps its section ID. All technical readings remain draft.
