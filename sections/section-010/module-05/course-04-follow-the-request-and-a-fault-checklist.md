---
draft: true
---
# Follow The Request With Hubble And A Fault Checklist

Status and logs tell you what the control plane thinks. Hubble tells you what the network did with a real request. This part follows a request with Hubble and ends with a list of faults and their signs.

## Observe a request with Hubble

Hubble records flows in the Cilium agent. If the `hubble` CLI is available, observe flows to a namespace while you send a request:

<!-- astrona:playground:renew -->

```sh
hubble observe --namespace starfleet --last 20
```

Look at the `verdict` column. `FORWARDED` means the packet went on, and `DROPPED` means a policy or a missing endpoint stopped it. A drop with the reason `Policy denied` points to a CiliumNetworkPolicy or a Kubernetes NetworkPolicy. If Hubble is not enabled in the playground, use `cilium monitor` inside the agent pod, which prints drops in the same way.

## Remember the ingress identity

Traffic that enters through a Gateway or Ingress reaches the backend pod from the Envoy proxy. Cilium gives this traffic the reserved identity `ingress`. A network policy on the backend must therefore allow traffic from the `ingress` entity, or the route will be healthy and the backend will still be unreachable. A policy that allows only the client pods does not help, because the backend never sees the client address.

## A fault checklist

| Symptom | Likely level | First check |
| --- | --- | --- |
| No GatewayClass, no status | Controller | CRDs, operator log, `enable-gateway-api` |
| Gateway not `Programmed` | Controller or listener | Gateway conditions, listener `message` |
| Route `Accepted=False` | Attachment | `sectionName`, host name overlap, `allowedRoutes` |
| Route `ResolvedRefs=False` | Reference | Backend name and port, `ReferenceGrant` |
| `404` from the Gateway | Match | Host name, path, Host header |
| `503` from the Gateway | Backend | Endpoints and pod readiness |
| No answer | Entry point | Generated Service, node port, network policy |
| Dropped in Hubble | Policy | Policy that allows the `ingress` entity |

Work the table top-down and stop at the first row that fits.

## Common pitfalls

> [!WARNING]
> Do not change several things at once: each change hides the effect of the one before. Re-read the status after every change, and compare `observedGeneration` with `generation`. Do not delete the generated Service or the `CiliumEnvoyConfig` to force a refresh, because the controller recreates them, and doing so interrupts traffic.
