---
draft: true
exam_objectives:
- Understand the Benefits of Gateway API over Ingress
---
# Gateway API Roles, Attachment And Delegation

Gateway API extends Kubernetes traffic-routing expression through resources with distinct ownership roles. It can represent listener configuration, route attachment and richer matching more explicitly than the traditional Ingress model. Its benefits depend on supported implementation features and deliberate delegation rather than simply using newer resource names.

## Separate The Owners

GatewayClass identifies a class of Gateway implementation and its controller relationship. Gateway describes listeners and infrastructure-facing traffic entry. Routes such as HTTPRoute describe application request matching and backend selection. These resources allow infrastructure and application teams to manage different responsibilities under defined permissions.

Traditional Ingress combines a narrower set of routing intent in one resource and often relies on implementation-specific annotations for additional behavior. Gateway API provides typed structures for many relationships, but a typed field still needs a controller that supports it. The resource model is a contract for implementation, not automatic packet forwarding.

## Attachment Is A Permission Relationship

A route names its intended parent through parent references. The Gateway's listener configuration determines which route kinds and namespaces may attach. Both sides must fit the supported attachment model. A route stored in a namespace does not automatically gain access to every Gateway.

Status conditions can explain whether a route was accepted, whether references resolved and whether the implementation programmed relevant state. Check the observed generation and applicable parent status rather than read one old condition as proof of the current declaration. Different stages can succeed or fail independently.

## Cross-Namespace References Need Consent

A route can need to reference a backend in another namespace. Supported cross-namespace references use an explicit permission model such as ReferenceGrant in the target namespace. The target owner grants a bounded relationship rather than allowing every resource to refer to every other tenant's objects.

A ReferenceGrant is not a general NetworkPolicy or RBAC grant. It authorizes the reference relationship within the Gateway API contract. Traffic reachability, endpoint readiness and application permission remain separate. A granted reference can therefore resolve correctly while the backend connection still fails.

## Richer Routing Has Limits

HTTPRoute can express supported hostname, path, header and backend relationships. Weighted backends can describe traffic-splitting intent where implemented. Other route kinds address different protocols and maturity levels. Check the chosen controller's feature support rather than assume every implementation handles every route kind identically.

Portability improves when a design uses standard supported fields instead of undocumented annotations. It is still bounded by conformance, feature support and deployment prerequisites. A resource accepted by the API can include intent that the selected controller cannot realize fully.

## Diagnose By Relationship

For an unavailable route, establish the class and controller, listener readiness, route attachment, matching criteria and backend references. Then inspect Service endpoints, policy and application behavior. A client reaching the listener does not prove that its host and path select the route. A valid route does not guarantee that a selected backend is ready.

This role-based model helps reviewers locate the responsible owner and correction. It also supports safer multi-tenant delegation when permissions are designed narrowly. Preserve status evidence and documented feature assumptions so future changes do not silently broaden attachment or rely on unsupported traffic behavior.

## Common pitfalls

> [!WARNING]
> Route existence is not attachment permission. ReferenceGrant authorizes a reference rather than all traffic or API actions, and standard fields still require compatible controller support.
