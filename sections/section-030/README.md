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

## Learning Path

The section has one module, **Gateway API Compared With Ingress**, with these parts in order:

1. The Limits Of Ingress
2. Gateway API Roles And Delegation
3. Expressiveness And Portability

The module has an ungraded playground, a graded lab (**Delegate Gateway Access By Namespace Label**) and a summary. The section closes with a capstone lab (**Share A Backend Across Namespaces With A Gateway**) and a knowledge check. The labs are untested and checked statically only.
