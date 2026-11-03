---
draft: true
---
# Filter Flows To Find A Fault

A busy cluster produces thousands of flows per second. Filters turn that into the few lines that answer your question. This part uses filters to find a dropped request and the policy behind it.

## The filters you will use

- `--namespace NS` selects flows to or from a namespace.
- `--pod NS/NAME` selects flows of one pod; `--from-pod` and `--to-pod` select one direction.
- `--verdict DROPPED` (or `FORWARDED`, `AUDIT`) selects by verdict.
- `--protocol http`, `dns` or `tcp` selects by protocol.
- `--last N` limits the output to the last N matches, and `--follow` streams.

Filters of different kinds are combined with AND.

## Find a drop

Create a policy that blocks `drifter` from `scout`, send a request, and find the drop:

<!-- astrona:playground:renew -->

```sh
cat <<'YAML' | kubectl apply -f -
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: scout-only-shuttle
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: scout
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
YAML
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null http://scout.starfleet.svc/
hubble observe --to-pod starfleet/scout --verdict DROPPED --last 5
```

The line shows `outpost/drifter` as the source, the pod `scout` as destination, and the verdict `DROPPED` with the reason `Policy denied`. This one line says which pod, which direction and why. The next step is to read the policies that select `scout`: `kubectl -n starfleet get cnp`.

## Check that a fix worked

After you change the policy, send the same request and watch for `FORWARDED`. Use `--follow` with the same filter while you test, so the result appears at once.

## From the source side

If the drop is on the egress of the client, `--from-pod outpost/drifter --verdict DROPPED` shows it, with the reason `Policy denied` and the event type `from-endpoint`. Look at both ends when you do not know which side blocks.

## Common pitfalls

> [!WARNING]
> Remember that a deny by a policy gives no reply, so the application only sees a timeout. The proof is in Hubble. A filter on `--pod` needs the form `namespace/name`. Do not use a very wide filter with `--follow` on a production cluster.
