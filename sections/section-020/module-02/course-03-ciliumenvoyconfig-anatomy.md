---
draft: true
---
# CiliumEnvoyConfig Anatomy

An annotation gives you a few settings. When you need your own Envoy rules, such as a weighted split or a retry policy, you write them in a `CiliumEnvoyConfig`. This part reads one and names its parts.

## Two resources

`CiliumEnvoyConfig` (short name `cec`) lives in a namespace. `CiliumClusterwideEnvoyConfig` (short name `ccec`) has no namespace and applies across the cluster. The spec has the same shape in both:

- `services` lists the Kubernetes Services whose traffic the configuration handles, by name, namespace and optional ports.
- `backendServices` lists Services that are used as Envoy clusters.
- `resources` is a list of raw Envoy objects: listeners, route configurations and clusters. Each one has an `@type` that names the Envoy type.

Cilium programs the node so that traffic to the listed Services goes to the Envoy listener you define.

## Read what Cilium generated

When you annotated the Service in the previous part, Cilium generated a configuration for it. Look at it:

<!-- astrona:playground:renew -->

```sh
kubectl get ciliumenvoyconfig -A
kubectl get ciliumclusterwideenvoyconfig
```

Depending on the Cilium version, the generated configuration for an annotated Service is a namespaced resource in the Service namespace, or an internal one that you do not see. Open one if it exists with `kubectl -n starfleet get ciliumenvoyconfig <name> -o yaml`, and find the `services` entry that names `probe-lb`, then the `Listener`, `RouteConfiguration` and `Cluster` objects in `resources`.

## The three Envoy objects

A request passes through three objects in order:

```mermaid
flowchart LR
  L["Listener"] --> R["RouteConfiguration"] --> C["Cluster"] --> E["Endpoints"]
```

The diagram shows the order. The **listener** accepts the connection and parses HTTP. The **route configuration** matches the request and picks a cluster, with optional weights and retries. The **cluster** holds the endpoints and the balancing policy.

## When to write your own

Writing a `CiliumEnvoyConfig` by hand means writing Envoy API configuration, which is detailed and version dependent. Check the Cilium documentation for the exact fields of your version, and test in a playground before production. For ordinary routing needs the Gateway API is simpler, and it produces this configuration for you.

## Common pitfalls

> [!WARNING]
> Do not edit a `CiliumEnvoyConfig` that Cilium generated for a Gateway or an annotated Service: the controller owns it and will overwrite your change. A mistake in a hand-written configuration can stop traffic for the Services it lists, so apply it first to a test Service.
