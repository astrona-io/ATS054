---
draft: true
---
# Deny Rules And Policy Precedence

Allow rules add paths. Sometimes you need the opposite: a path that must stay closed whatever other policies say. Cilium has explicit deny rules for that.

## Deny rules

The fields `ingressDeny` and `egressDeny` have the same selectors as `ingress` and `egress`, but they block. **A deny rule wins over any allow rule.** This lets a platform team close a path that application teams cannot reopen. Save this as `deny-drifter.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: deny-drifter
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: scout
  ingressDeny:
    - fromEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: outpost
```

<!-- astrona:playground:renew -->

```sh
kubectl apply -f deny-drifter.yaml
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The first prints `000`, because pods from `outpost` are denied. The second prints `200`: a policy with only a deny section does not turn on default deny for the others, so `shuttle` is not affected.

## How policies combine

All policies that select a pod are added together:

1. If any deny rule matches, the traffic is dropped.
2. Otherwise, if the pod is in default deny for that direction, the traffic is allowed only if some allow rule matches.
3. Otherwise the traffic is allowed.

There is no order among policies and no priority number, so adding a policy never removes an allow rule that another policy gives, except through a deny.

## Policy audit mode

Before you enforce a new policy on a live workload, you can put an endpoint in audit mode, where Cilium logs what it would drop and allows it. Check the Cilium documentation for the way to set it in your version. Combine it with Hubble to see the would-be drops.

## Common pitfalls

> [!WARNING]
> A deny rule cannot be overridden, so a mistake in one can block a system component, for example the API server or DNS. Keep deny selectors narrow. Test with `hubble observe --verdict DROPPED` after each change.
