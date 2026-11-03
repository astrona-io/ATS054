---
draft: true
---
# Verify And Roll Back

Every step of the migration needs two things: a check that says it worked and a way to undo it. Write both before you start the step.

## Checks

| What | How |
| --- | --- |
| Pods are ready and have no proxy container | `kubectl get pods -o custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name` |
| Traffic still works | A request from a client pod, with the expected status code |
| Policy decides as before | `hubble observe --verdict DROPPED` shows no drops that you did not expect |
| Layer 7 rules are enforced | A request that must be denied gets `403` |
| The node proxy is healthy | `kubectl -n kube-system get daemonset cilium-envoy` shows all pods ready |
| Errors did not grow | The error rate and latency of the application, from your own monitoring |

<!-- astrona:playground:renew -->

```sh
agent() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- "$@"; }
agent hubble observe --verdict DROPPED --last 10
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

## Rollback

Each step has an opposite:

- Step "stop injection" is undone by adding the label again and restarting the workloads.
- Step "add Cilium policies" is undone by deleting the policies you added, if you kept them in their own files in Git.
- Step "remove old mesh objects" is the one with no easy way back. Keep a copy of the objects (`kubectl get -o yaml`) until the namespace has run for an agreed time.

Decide beforehand who may start a rollback and what signal triggers it, for example an error rate above a number for five minutes.

## After the last namespace

Remove the old mesh control plane, its webhooks and its CRDs only after every namespace has run without it for a while. Check for leftover webhooks, which can block new pods if their service is gone.

```sh
kubectl get mutatingwebhookconfigurations
kubectl get validatingwebhookconfigurations
```

## Common pitfalls

> [!WARNING]
> A webhook that points at a deleted service can reject every new pod. Remove the webhook configurations before or together with the old control plane, and test by creating a pod.
