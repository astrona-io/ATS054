# Overview: Sidecar And Sidecarless Mesh Architectures (Playground)

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

- List the containers of every pod with `kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CONTAINERS:.spec.containers[*].name`.
- List the mutating webhooks with `kubectl get mutatingwebhookconfigurations`.
- Compare the DaemonSets `cilium` and `cilium-envoy` in `kube-system`, and find on which node each pod runs.
- Run `cilium-dbg status` and `cilium-dbg endpoint list` in the agent with `kubectl -n kube-system exec ds/cilium -c cilium-agent -- ...`.
- Apply a Layer 7 policy and check that the application pods keep their age.
- Restart `cilium-envoy` with `kubectl -n kube-system rollout restart daemonset/cilium-envoy` and watch the application pods.
