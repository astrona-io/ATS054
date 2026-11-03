# Overview: Sidecarless Architecture In Practice (Playground)

This is a playground, not a lab. It starts a cluster with Cilium and the example workloads, and then waits. There is no task, no `astrona submit` and no pass or fail. Look at the architecture, change policies, run `astrona destroy`, and start over.

## What is in the box

- A `kind` cluster with one control-plane node and one worker node. `kubectl` already points at it.
- Cilium with kube-proxy replacement, the `cilium-envoy` DaemonSet and Hubble.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` | podinfo, Service port 80, pod port 9898 |
  | `starfleet` | `probe` | go-httpbin, Service port 80, pod port 8080 |
  | `starfleet` | `shuttle` | A pod with `curl` |
  | `outpost` | `drifter` | A pod with `curl` in another namespace |

- No `CiliumNetworkPolicy` exists. Every pod has exactly one container.

## Practice tasks

- Count the pods and containers: `kubectl get pods -A -o wide`.
- Read the requests and limits of the `cilium` and `cilium-envoy` containers in the DaemonSets.
- Scale `scout` to three replicas and count the proxies again.
- Restart `cilium-envoy` with `kubectl -n kube-system rollout restart daemonset/cilium-envoy` while you send requests from `shuttle`, and read the result.
- Apply a Layer 7 policy, then read `agent cilium-dbg status` for the proxy line.
- Find the Prometheus port of the Envoy pods (9964) in the DaemonSet.
