# Overview: Choose And Migrate A Mesh Architecture (Playground)

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

- List the container names of every pod with `kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CONTAINERS:.spec.containers[*].name`.
- Add a label `sidecar.example.io/inject=true` to `outpost` and remove it again.
- Write a Layer 7 policy for `probe` that allows `GET` on `/get` only and test it from `shuttle`.
- Write the parity table for a service: retries, timeouts, mutual TLS, authorization, and the Cilium feature for each.
- Run a canary: apply the policy to one namespace and compare the flows with `agent hubble observe`.
- Write down a rollback step for each change you make.
