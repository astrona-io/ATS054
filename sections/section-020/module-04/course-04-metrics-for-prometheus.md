---
draft: true
---
# Metrics For Prometheus

Flows answer questions about single requests. Metrics answer questions about rates over time: how many drops per minute, how many DNS errors, how many HTTP 5xx. This part lists where Cilium publishes metrics and how to choose them.

## Four endpoints

With Prometheus metrics turned on in the Helm chart (`prometheus.enabled=true`), Cilium exposes several metric endpoints:

- the **agent** on port 9962, with datapath, policy and endpoint metrics;
- the **operator** on port 9963 (with `operator.prometheus.enabled=true`);
- the **Envoy** proxy on port 9964 (with `envoy.prometheus.enabled=true`);
- **Hubble** on port 9965 (with `hubble.metrics.enabled`), with metrics built from flows.

Each runs on every node, so Prometheus scrapes the pods, or a `ServiceMonitor` does when you use the Prometheus Operator (`prometheus.serviceMonitor.enabled=true`).

## Hubble metric groups

You choose Hubble metrics by group in the Helm value `hubble.metrics.enabled`, for example `{dns,drop,tcp,flow,port-distribution,icmp,httpV2}`. Pick by question:

| Question | Group |
| --- | --- |
| How many packets are dropped, and why? | `drop` |
| Which DNS queries fail? | `dns` |
| How many requests, and which status codes? | `httpV2` |
| How many TCP connections and flags? | `tcp` |
| What is the flow rate per verdict? | `flow` |

HTTP metrics appear only for traffic that goes through Envoy, as in the previous part.

## Look at a metric

Forward the agent metrics port and read the counters:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system port-forward ds/cilium 9962:9962 &
curl -s localhost:9962/metrics | grep -E '^cilium_(drop|forward)_count_total' | head
```

If the port is not served, Prometheus metrics are off in this playground, and you can read the Helm value that enables them. Lines such as `cilium_drop_count_total{direction="INGRESS",reason="Policy denied"}` give the drop count by reason. A counter only grows, so graph its rate.

## Alert on what matters

A good first alert is a rise in drops with the reason `Policy denied` right after a release, because it means a new policy or a new caller. A second one is a rise in DNS errors. Keep the labels of the metrics low in number so the series stay manageable.

## Common pitfalls

> [!WARNING]
> Each metric group adds series, and HTTP groups with many labels can add a lot, so enable only what you will use. Metric names and labels change between versions, so check the reference of your version. A metrics endpoint that is open to the network should be protected by a network policy.
