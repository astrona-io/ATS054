---
draft: true
exam_objectives:
- Understand the Benefits of Gateway API over Ingress
---
# Understand the Benefits of Gateway API over Ingress

This section explains what the Ingress API cannot express and how the Gateway API answers it with separate resources for separate roles. It practises delegation with allowedRoutes and cross-namespace references with ReferenceGrant.

## Learning Outcomes

- List what the Ingress spec can and cannot express.
- Explain the roles of the GatewayClass, the Gateway and the route.
- Choose an allowedRoutes setting and read the Accepted and ResolvedRefs conditions.
- Create a narrow ReferenceGrant and explain what portable means for a route.
- Migrate an Ingress to a Gateway and an HTTPRoute with a cutover and rollback plan.
- Read the release channel, support levels and extension points of a Gateway API install.

## Learning Path

The section has three modules. The first, **Gateway API Compared With Ingress**, has these parts in order:

1. The Limits Of Ingress
2. Gateway API Roles And Delegation
3. Expressiveness And Portability

The second, **Migrate From Ingress To Gateway API**, covers planning, translating, cutting over and rolling back a migration. The third, **Gateway API Channels, Conformance And Extensions**, has these parts in order:

1. Release Channels And Versions
2. Support Levels And Conformance
3. Extension Points
4. Upgrade And Compatibility

Each module has an ungraded playground, a graded lab (**Delegate Gateway Access By Namespace Label**, **Migrate An Ingress To A Gateway And An HTTPRoute** and **Inventory The Gateway API Of A Cluster**) and a summary. The section closes with a capstone lab (**Share A Backend Across Namespaces With A Gateway**) and a knowledge check. The labs are untested and checked statically only.
