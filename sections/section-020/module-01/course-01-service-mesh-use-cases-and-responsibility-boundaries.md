---
draft: true
exam_objectives:
- Service Mesh Use Cases
---
# Service Mesh Use Cases And Responsibility Boundaries

A service mesh supplies capabilities for communication among services, such as traffic management, visibility and selected security controls. The term describes a set of responsibilities rather than one universal deployment pattern. Cilium can implement relevant capabilities through its datapath and supported proxy arrangements, but each feature has its own prerequisites and trust boundary.

## Start With A Communication Need

Traffic management can route requests to selected versions or destinations according to supported rules. Visibility can expose service relationships, verdicts and application-protocol information where available. Security can include network authorization, transport encryption or authenticated identity under specific feature configurations.

A deployment may need only some of these capabilities. Installing a networking component does not establish that every mesh feature is enabled. Define the required behavior and inspect its supported implementation instead of treating the label service mesh as proof of universal protection.

## Discovery Is Not Request Routing

A Service or DNS name helps locate a destination. Application-aware routing can select a destination using host, path or other protocol context. Those responsibilities are related but different. A DNS lookup can succeed while a proxy rejects the request's route, and a valid route can point to a backend that is not ready.

Traffic splitting also depends on the supported controller or proxy arrangement. A declared percentage is not automatically a guarantee of the same proportion of users or business transactions because connections, retries and routing behavior influence observations. Evaluate the actual request population and measurement evidence.

## Proxies And Datapaths Cooperate

eBPF can handle supported networking operations at kernel hooks. A proxy can interpret application protocols and apply request-level behavior. A sidecarless arrangement can share proxy infrastructure instead of placing one proxy container in every application Pod. That changes resource use, operational ownership and failure scope.

Shared infrastructure does not mean no proxy is involved. It also does not mean that every request can be inspected when its application payload is encrypted beyond the proxy's visibility. Protocol support and termination points determine what context is available for routing or policy.

## Separate Security Claims

Transport encryption protects bytes over a defined segment. Authentication establishes a peer identity under a trust model. Authorization decides which operations that identity may perform. These claims can use related mechanisms, but one should not be silently substituted for another.

Transparent node-to-node encryption does not necessarily establish the same application identity contract as mutual TLS between services. A network policy can permit a connection without authorizing every application endpoint. Application credentials and business rules remain relevant even when the transport and network policy are correctly configured.

## Evaluate Operational Consequences

A proxy or control-component failure can affect a different population from a node-routing failure. Shared proxies can centralize upgrades but also broaden the impact of a local dependency. Observability records can show permitted traffic while the application returns errors. Define which observations establish routing, policy and useful service separately.

For a mesh use case, map the requesting workload, selected destination, processing point, identity source and relevant evidence. Include retries, timeouts and failure handling where they affect the application contract. The result should explain what the feature provides and what still belongs to the application or infrastructure rather than promise automatic correctness.

## Common pitfalls

> [!WARNING]
> Sidecarless does not mean proxy-free. Discovery, application routing, transport encryption, peer authentication and business authorization are different responsibilities with separate evidence.
