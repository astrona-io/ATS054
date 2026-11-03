---
draft: true
---
# Observability With Hubble And Metrics

A mesh that you cannot see is a mesh that you cannot trust. When a call fails, three questions come first: did the request leave the client, did the network and the policy let it through, and what did the server answer. Cilium answers them with Hubble, which watches the traffic in eBPF and the Envoy proxy, and with metrics that Prometheus can scrape.

Keep one sentence in mind for this module: **Hubble records one flow per packet event with its source, destination, verdict and, if a Layer 7 rule applies, its HTTP details, and metrics turn the same events into counters.** You will read flows with the CLI, filter them, make HTTP visible, and know which metrics to turn on and where to scrape them.

The module has four parts. **Read Flows With The Hubble CLI** covers the commands and the fields. **Filter Flows To Find A Fault** narrows the output by verdict, protocol and pod. **Layer 7 Visibility And Service Maps** explains why HTTP needs a Layer 7 rule and shows the service map. **Metrics For Prometheus** lists the endpoints and the metric groups.

## Learning objectives

After this module you can:

- Read the source, destination, verdict and type of a Hubble flow.
- Filter flows by namespace, pod, verdict and protocol.
- Explain why HTTP details appear only for traffic that passes a Layer 7 rule.
- Name the metrics endpoints of the agent, the operator, Envoy and Hubble.
- Choose Hubble metric groups for a given question.

## Before you start

You need the policies from the previous modules and `kubectl exec`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Envoy proxy, Hubble and Hubble Relay. The `hubble` and `cilium` command-line tools may or may not be installed on your machine; the parts say what to do in each case.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
