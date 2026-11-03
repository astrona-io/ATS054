---
draft: true
---
# Summary

An Ingress holds a host, paths, a backend and a certificate in one object. It has no field for header matching, weights, redirects or rewrites, so each controller adds annotations, and an annotation with a wrong key is accepted without an error. The one object also mixes the work of the infrastructure provider, the cluster operator and the application developer, so RBAC cannot give a developer the routes and keep the listener for the platform team.

The Gateway API separates the roles into three resources. A GatewayClass names the controller. A Gateway defines listeners and belongs to the cluster operator. An HTTPRoute holds matches, filters and backends and belongs to the application developer. A route attaches only when both sides agree: the route names the Gateway in `parentRefs`, and the listener allows the namespace with `allowedRoutes`. The values are `Same`, `All` and `Selector`, and `Same` is the default.

A ReferenceGrant in the namespace of a Service allows routes from named namespaces to use that Service. Without it, the route reports `ResolvedRefs=False` with the reason `RefNotPermitted`. The route status shows `Accepted`, `ResolvedRefs` and a reason for every parent, so a mistake is read from the API and not guessed.

A route can match on path, headers, query parameters and method, split traffic by weight and change requests with standard filters. Portability comes from a published specification, a standard and an experimental channel, common status conditions and conformance tests. Each controller documents which features it supports.

- One Ingress mixes three roles. The Gateway API has one resource for each role.
- `allowedRoutes` on the listener decides which namespaces attach. The default is `Same`.
- A ReferenceGrant lives in the namespace of the target Service.
- `Accepted=True` and `ResolvedRefs=True` are two different checks.
- A feature in the experimental channel may not be supported by every controller.

<!-- astrona:playground:destroy -->
