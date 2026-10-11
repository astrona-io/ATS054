---
draft: true
exam_objectives:
- Sidecar-based versus Sidecarless Architectures
---
# Sidecar And Shared-Proxy Architecture Tradeoffs

Proxy placement changes how service communication features are delivered and operated. A sidecar arrangement places a proxy alongside each application workload, commonly in the same Pod. A sidecarless arrangement can use shared node-level proxy infrastructure and datapath redirection for selected processing. Neither name alone establishes the exact feature set or security guarantee.

## Per-Workload Proxy Placement

A sidecar proxy can intercept or participate in the workload's traffic under the configured arrangement. Its resource use, configuration and lifecycle are associated with the Pod. Application replacement can also replace the proxy, while a proxy upgrade can require workload rollout depending on the system.

This placement can provide per-workload configuration and failure boundaries, but adds containers and resource overhead across replicas. Startup ordering and readiness can affect application connectivity. A proxy container running beside an application does not automatically mean every relevant traffic path is intercepted or correctly authenticated.

## Shared Processing Moves The Boundary

Cilium can use eBPF-based datapath mechanisms to redirect selected traffic to shared application-aware processing such as Envoy. This avoids requiring a separate proxy container in every application Pod for those supported features. Kernel-level operations and proxy operations remain different responsibilities.

Shared placement changes operational ownership. A node proxy's availability or configuration can affect multiple workloads, while an individual application restart need not replace the shared proxy. This can reduce duplicated overhead but creates a shared dependency whose capacity and failure scope require review.

## Protocol Processing Still Matters

Address forwarding and port filtering can happen without parsing an HTTP request. Method, path and other application-level decisions require appropriate protocol context. Calling a design sidecarless does not make that context unnecessary or cause encrypted payloads to become universally visible.

The supported processing point and termination arrangement determine what a proxy can inspect. A TLS-protected application connection can retain end-to-end protection across a shared network path, but an intermediate feature may then lack request-level visibility unless a supported mechanism provides it. State the actual path rather than infer behavior from architecture terminology.

## Compare Lifecycle And Resource Tradeoffs

Per-Pod proxies distribute resource consumption with replica count. Shared processing concentrates some cost at nodes or other common components. Capacity planning should consider traffic volume and enabled features rather than assume shared means free. Different failure points can produce different affected populations.

Upgrades need compatible versions and supported sequencing in either design. A shared component can centralize maintenance, while a sidecar rollout can couple maintenance to workloads. Configuration drift, old replicas and mixed state can occur in both arrangements. Review which owner controls the feature and how convergence is observed.

## Security Is A Configured Contract

Encryption, peer authentication, network permission and application authorization are distinct mechanisms. A sidecar may implement some of them, while a shared architecture may implement others through different paths. Neither placement automatically grants or removes business authority.

For a design decision, identify the desired feature, its processing point, identity source, protected segment and failure evidence. Then evaluate cost and operational responsibilities. A useful comparison explains which relationships change with proxy placement and which application or infrastructure controls remain necessary.

## Common pitfalls

> [!WARNING]
> Sidecarless does not mean proxy-free or cost-free. Placement changes lifecycle and failure scope, while security guarantees still require explicit mechanisms and path coverage.
