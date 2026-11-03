---
draft: true
---
# Support Levels And Conformance

Two controllers can both say "we support the Gateway API" and still differ. The specification defines what an implementation must support, what it may support, and how it proves it. This part explains the levels and where to see them.

## Three support levels

Each feature of the API has a support level:

- **Core**: every implementation must support it. A portable route uses only Core features.
- **Extended**: part of the standard, but an implementation may or may not support it. If it supports it, the behaviour is defined. Examples are some header and rewrite options.
- **Implementation-specific**: the standard allows it, but the behaviour is up to the implementation and may differ.

The practical rule is that a route using Core features works everywhere, a route using Extended features works where the controller says it supports them, and a route using implementation-specific features is tied to one controller.

## Conformance

The project has a **conformance test suite**. An implementation runs it against a cluster and can publish a report. Reports are grouped by **profile**, such as the profiles for HTTP, TLS and gRPC gateways, and list which Core and Extended features passed. The reports are in the Gateway API repository, so you can check a controller version before you rely on a feature. Read the report for the Cilium version you run, not for the latest.

## What the controller tells you

A GatewayClass can list the features its controller supports in its status. Read it:

<!-- astrona:playground:renew -->

```sh
kubectl get gatewayclass cilium -o yaml
```

Look at the `status.conditions` first: `Accepted` must be `True`. If the status has a `supportedFeatures` list, it names the features the controller reports. Whether this field is filled depends on the Gateway API version and the controller version, so an empty list does not mean nothing is supported.

## What a route tells you

When a route uses a feature the controller does not support, the route status says so. The condition `Accepted` may be `False` with the reason `UnsupportedValue`, or the condition `ResolvedRefs` may be `False` with the reason `InvalidKind`. Always read the status after you apply a route that uses a feature you have not used before.

## Common pitfalls

> [!WARNING]
> A passing conformance report is not a promise about your configuration. Test your own routes. Do not assume a feature is supported because the field is in the schema: the API server accepts the field, and only the controller decides whether it works.
