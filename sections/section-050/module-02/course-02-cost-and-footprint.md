---
draft: true
---
# Cost And Footprint

The strongest argument for the sidecarless design is arithmetic. A sidecar costs memory and CPU in every pod. A node proxy costs it once per node.

## A worked comparison

Say a cluster has 10 nodes and 400 application pods, and a proxy needs 50 MiB of memory at rest.

- **Sidecar per pod**: 400 proxies x 50 MiB = 20,000 MiB, about 20 GiB, only for the idle proxies.
- **Proxy per node**: 10 proxies x 50 MiB = 500 MiB. The node proxy handles more traffic, so give it more headroom, for example 4 times the memory: 2,000 MiB.

The difference is large, and it grows with the density of pods. The numbers are an example: measure your own proxy and your own traffic.

## What else a sidecar costs

- **Start time**: a pod is not ready until its sidecar is ready, and ordering problems between the application and the sidecar are common.
- **Jobs and short pods**: a pod that finishes must also stop its sidecar, or the job never completes.
- **Scheduling**: every pod requests extra CPU and memory, so fewer pods fit on a node.
- **Latency**: each request passes through two proxies, one at each side, in the sidecar design.

## What the node proxy costs

- One more DaemonSet to size and watch.
- A shared resource: a busy tenant can use the capacity that others need, so set requests and limits for `cilium-envoy`.
- Layer 7 work only for the traffic that a rule selects. Layer 3 and Layer 4 traffic does not go through it.

## Measure

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get daemonset cilium cilium-envoy -o jsonpath='{range .items[*]}{.metadata.name}{" requests: "}{.spec.template.spec.containers[0].resources.requests}{"\n"}{end}'
kubectl -n starfleet scale deployment scout --replicas=3
kubectl -n starfleet get pods -o wide
kubectl -n kube-system get pods -l k8s-app=cilium-envoy
```

The count of `cilium-envoy` pods does not change when you scale `scout`. Scale back to 1 afterwards.

## Common pitfalls

> [!WARNING]
> Do not claim a saving without a measurement. The benefit depends on the pod density, the traffic that needs Layer 7 and the size of the proxies. If almost no traffic needs Layer 7, both designs are cheap.
