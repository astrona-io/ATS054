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
- Prove from the cluster that the proxies follow the node count, and measure the footprint.
- Choose a design per workload and migrate one namespace at a time with a check and a rollback.

## Learning Path

The section has three modules. The first, **Sidecar And Sidecarless Mesh Architectures**, has these parts in order:

1. How A Sidecar Mesh Works
2. Cilium Sidecarless Architecture
3. Comparing Sidecar, Sidecarless And Ambient Designs

The second, **Sidecarless Architecture In Practice**, has these parts in order:

1. What Runs Where
2. Cost And Footprint
3. Upgrades And Failure Scope
4. Security Boundaries And Trade-offs

The third, **Choose And Migrate A Mesh Architecture**, has these parts in order:

1. Decision Factors
2. Inventory And Feature Mapping
3. Migrate One Namespace At A Time
4. Verify And Roll Back

Each module has an ungraded playground, a graded lab (**Remove A Leftover Sidecar Proxy**, **Prove The Cluster Runs Without Sidecars** and **Inventory A Cluster Before A Sidecar Migration**) and a summary. The section closes with a capstone lab (**Migrate Two Services From Sidecars To The Node Proxy**) and a knowledge check. The labs are untested and checked statically only.
