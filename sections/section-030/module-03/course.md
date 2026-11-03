---
draft: true
---
# Gateway API Channels, Conformance And Extensions

The Gateway API is not one fixed set of objects. It ships in release channels, it grows by feature, and each implementation supports a part of it. A route that works on one controller may use a field that another controller ignores. Knowing the channels, the support levels and the extension points tells you what you can rely on and what you must test.

Keep one sentence in mind for this module: **the channel decides which kinds exist in the cluster, the support level decides which fields every implementation must honour, and an extension point is the place where an implementation may add its own behaviour.** You will read what a cluster has installed, check what the controller reports, read the support levels, and use an extension point without losing portability.

The module has four parts. **Release Channels And Versions** reads the installed CRDs. **Support Levels And Conformance** explains Core, Extended and implementation-specific features. **Extension Points** covers `ExtensionRef`, `parametersRef` and policy attachment. **Upgrade And Compatibility** plans a CRD upgrade.

## Learning objectives

After this module you can:

- Tell the standard channel from the experimental channel and read the installed version.
- Name the three support levels and say what conformance profiles prove.
- Use `ExtensionRef`, `parametersRef` and policies as extension points.
- Read GatewayClass and route status to find an unsupported feature.
- Plan an upgrade of the Gateway API CRDs.

## Before you start

You need the Gateway API objects from the previous modules and `kubectl get -o jsonpath`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Ingress controller and the Gateway API controller, with the CRDs of the experimental channel installed. The `GatewayClass` is named `cilium`.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
