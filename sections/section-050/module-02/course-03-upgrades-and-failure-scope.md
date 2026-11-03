---
draft: true
---
# Upgrades And Failure Scope

Cost is one axis. The other is what happens when you upgrade a part or when it fails: who is affected, and how many.

## Upgrades

- **Sidecar**: a new proxy version needs a restart of every pod that has it. That is a rollout of all the workloads, often owned by many teams.
- **Sidecarless**: the proxy is in a DaemonSet that the platform team owns. A rolling update goes node by node. Application teams do not restart anything.

Upgrade the Cilium agent and the Envoy DaemonSet together or in the order that the release notes give, and use a rolling update with a limit on how many nodes are changed at once.

## Failure scope

- **Sidecar**: a failing proxy affects one pod. The blast radius is small, but it happens to many pods at the same time when a bad version rolls out.
- **Node proxy**: a failing `cilium-envoy` affects the Layer 7 traffic of the pods on that node. Traffic that uses only Layer 3 and Layer 4 rules keeps working, because the kernel handles it.

So the node proxy has a larger blast radius per failure and fewer places to fail. Watch it as part of the platform.

## Try it

Send requests in a loop from `shuttle` and restart the proxy:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- sh -c 'for i in $(seq 1 30); do curl -s -m 2 -o /dev/null -w "%{http_code} " http://scout.starfleet.svc/; sleep 1; done; echo' &
kubectl -n kube-system rollout restart daemonset/cilium-envoy
kubectl -n kube-system rollout status daemonset/cilium-envoy --timeout=120s
wait
```

Without a Layer 7 policy, the requests go through the kernel and all return `200`: the proxy restart does not touch them. Apply a Layer 7 rule for `scout` and repeat to see the Layer 7 traffic fail for a few seconds on the node that restarts.

## Common pitfalls

> [!WARNING]
> A restart of the proxy while Layer 7 traffic runs breaks connections on that node. Do upgrades in a maintenance window, one node at a time, and check that the readiness of each pod is true before the next node starts.
