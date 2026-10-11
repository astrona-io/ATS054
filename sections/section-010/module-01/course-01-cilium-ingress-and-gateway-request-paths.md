---
draft: true
exam_objectives:
- Know How to use Ingress or Gateway API for Ingress Routing
---
# Cilium Ingress And Gateway Request Paths

External routing begins with a request's destination, protocol, host and path. Ingress or Gateway API resources express how that request should reach an application, but an enabled implementation must realize their intent. Cilium can provide this implementation using its supported proxy and networking arrangements. The resulting path still contains several independently configured relationships.

## Select The Responsible Implementation

An Ingress uses a class relationship to identify the intended controller. Gateway API separates GatewayClass, Gateway and route resources, allowing infrastructure and application owners to describe different parts of the path. Cilium's relevant feature must be enabled with supported prerequisites and resource definitions.

A resource stored by Kubernetes is not evidence that the intended controller accepted or programmed it. Inspect ownership and supported status conditions. An unrelated controller's address or a stale status can mislead a reviewer who assumes every installed implementation interprets the same resource automatically.

## Listener And Route Must Agree

The client must reach an exposed address and listener using the expected protocol. A route can then match hostname, path or other supported criteria and select a backend. Gateway route attachment also depends on the parent relationship and allowed route rules. A route that exists but is not accepted by its parent cannot provide the intended traffic behavior.

Suppose a listener is reachable but the request uses a hostname outside the route's match. The proxy can reject or fail to select the intended backend even while TCP succeeds. The correction belongs to the declared request and routing contract, not a broad change to Pod policy.

## Cilium's Proxy Is Part Of The Path

Selected ingress and Gateway behavior uses Envoy-based processing under the deployment's supported arrangement. Cilium realizes generated proxy configuration from the routing resources. Direct low-level proxy configuration can conflict with generated state and should be treated as an administrative implementation detail requiring care.

The proxy's listener and route state can fail independently of Pod routing. A valid application route can also target a Service with no ready endpoints or the wrong port. Trace proxy-to-Service-to-endpoint relationships rather than assume that a successful controller deployment proves backend usefulness.

## TLS Has A Defined Boundary

A TLS listener needs appropriate certificate material and hostname coverage. The client validates the server identity under its trust configuration. A certificate stored in a Secret does not establish that the listener loaded it or that its name and lifetime fit the client request.

Termination means the encrypted client connection ends at that point. The backend connection can use a separate encrypted or plaintext protocol according to configuration. Do not claim end-to-end encryption solely because the public listener serves HTTPS. Application authentication and authorization are also independent of transport confidentiality.

## Evaluate The Complete Request

After routing, the selected backend must be ready, listening and able to perform the requested operation. Network policy may constrain the relevant proxy-to-endpoint relationship. The observed source context can differ from the original client depending on implementation and forwarding behavior, so policy review needs the actual supported path.

Diagnose discovery, external exposure, listener acceptance, route matching, backend selection, policy and application response in order. Each successful stage narrows the remaining problem without proving the entire path. This method preserves security intent while correcting the demonstrated broken relationship.

## Common pitfalls

> [!WARNING]
> API acceptance is not listener programming. TLS termination covers a defined segment, and correct route intent still needs valid attachment, ready backends and permitted application traffic.
