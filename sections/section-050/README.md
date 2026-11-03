---
draft: true
exam_objectives:
- Sidecar-based versus Sidecarless Architectures
---
# Sidecar-based versus Sidecarless Architectures

This section compares the sidecar design, the sidecarless design of Cilium and the ambient design. It shows where Cilium puts the kernel programs and the Envoy proxy, and what each placement means for cost, upgrades, failure scope and security boundaries.

## Learning Outcomes

- Explain how a sidecar is injected and how traffic is redirected to it.
- Name the pieces of the Cilium architecture and where each runs.
- Say which traffic reaches Envoy and which stays in the kernel.
- Compare the designs on resource use, upgrades, failure scope and security boundary.

## Learning Path

The section has one module, **Sidecar And Sidecarless Mesh Architectures**, with these parts in order:

1. How A Sidecar Mesh Works
2. Cilium Sidecarless Architecture
3. Comparing Sidecar, Sidecarless And Ambient Designs

The module has an ungraded playground, a graded lab (**Remove A Leftover Sidecar Proxy**) and a summary. The section closes with a capstone lab (**Migrate Two Services From Sidecars To The Node Proxy**) and a knowledge check. The labs are untested and checked statically only.
