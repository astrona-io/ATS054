---
draft: true
---
# Default Deny And Identity-Based Rules

Without a policy, every pod can reach every pod. This part restricts one pod and then opens exactly the paths it needs, using the labels that Cilium turns into identities.

## When default deny starts

A pod is **not** restricted until a policy selects it. When a policy selects the pod and has an `ingress` section, the pod accepts only the ingress that some rule allows. When it has an `egress` section, the pod may send only what some rule allows. The two directions are separate: a policy with only `ingress` leaves egress open.

Check that nothing is restricted yet:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

Both print `200`.

## Restrict probe and allow shuttle

Save this as `probe-ingress.yaml`. It selects `probe` and has one ingress rule that allows pods with the label `app: shuttle` in the same namespace, on the pod port 8080:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-ingress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
```

```sh
kubectl apply -f probe-ingress.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

The first request prints `200`. The second prints `000` after five seconds, because the packet was dropped and not answered.

## Why a label is an identity

Cilium does not look at IP addresses to decide. It gives every set of pod labels a numeric **identity** and writes rules in terms of identities, so the rule keeps working when pods move or restart. The matching is by label in the same namespace unless you add a namespace label to the selector. Add `k8s:io.kubernetes.pod.namespace: outpost` next to the label to select a pod in another namespace.

## A Kubernetes NetworkPolicy works too

Cilium also enforces the standard Kubernetes `NetworkPolicy`. A default deny for every pod of a namespace is the empty selector and the policy type:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Use the standard kind for rules that every CNI supports, and the Cilium kind for Layer 7, names and entities.

## Common pitfalls

> [!WARNING]
> The pod port matters, not the Service port: Cilium checks the policy after the Service is translated to a pod. Remember DNS: an egress default deny also blocks the name lookup. A dropped packet gives no reply, so a client sees a timeout, not an error.
