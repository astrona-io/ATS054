---
draft: true
---
# Migrate From Ingress To Gateway API

Most clusters that adopt the Gateway API do not start empty. They already have Ingress objects that carry real traffic, and the move has to happen without an outage. The Gateway API and the Ingress API can run side by side in the same cluster, and Cilium implements both, so you can build the new entry point, test it, and switch traffic when you are ready.

Keep one sentence in mind for this module: **translate the Ingress field by field into a Gateway and an HTTPRoute, run both, test the new entry point with a `Host` header, move the DNS name, and delete the Ingress last.** You will map the fields, deal with the annotations that have no direct equivalent, try the conversion tool, and plan a cutover that can be rolled back.

The module has four parts. **Map Ingress Fields To Gateway API** gives the translation table. **Replace Annotations With Fields And Filters** covers redirects, rewrites and timeouts. **Convert With ingress2gateway** shows the conversion tool and how to review its output. **Plan A Cutover With A Rollback** runs both entry points and switches traffic safely.

## Learning objectives

After this module you can:

- Translate hosts, paths, backends and TLS from an Ingress to a Gateway and an HTTPRoute.
- Replace common controller annotations with Gateway API fields and filters.
- Use a conversion tool and review what it cannot convert.
- Run Ingress and Gateway side by side and test before the switch.
- Write a cutover plan with a rollback step.

## Before you start

You need to know the fields of an `Ingress` and the basic Gateway API objects: `Gateway`, listener and `HTTPRoute`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Ingress controller (dedicated mode) and the Gateway API controller. The IngressClass and the GatewayClass are both named `cilium`.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

No `Ingress` or `Gateway` exists yet. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
