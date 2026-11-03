# Overview: Observability With Hubble And Metrics (Playground)

This is a playground, not a lab. It starts a cluster with Cilium and the example workloads, and then waits. There is no task, no `astrona submit` and no pass or fail. Write policies, break them, run `astrona destroy`, and start over.

## What is in the box

- A `kind` cluster with one control-plane node and one worker node. `kubectl` already points at it.
- Cilium with kube-proxy replacement, the `cilium-envoy` DaemonSet, Hubble and Hubble Relay. No sidecar proxy runs in any pod.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` | podinfo, Service port 80, pod port 9898 |
  | `starfleet` | `probe` | go-httpbin, Service port 80, pod port 8080 |
  | `starfleet` | `shuttle` | A pod with `curl` |
  | `outpost` | `drifter` | A pod with `curl` in another namespace |

- No `CiliumNetworkPolicy` exists, so every pod can reach every other pod.

## Helpers

Paste these once in each new terminal. `from_shuttle` and `from_drifter` send a request from the client pod and print the HTTP status code (`000` means no reply). `flows` reads recent Hubble flows from the agent.

```sh
from_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' "$@"; }
from_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' "$@"; }
flows() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe "$@"; }
```

Use them like this: `from_shuttle http://probe.starfleet.svc/get` and `flows --namespace starfleet --last 10`.

## Practice tasks

- Run `hubble observe --namespace starfleet --last 20` while you send requests from `shuttle`.
- Filter the flows by `--verdict DROPPED` after you apply a deny policy.
- Apply an HTTP rule and read the method and URL with `--protocol http`.
- Open the Hubble UI with `cilium hubble ui` if it is installed.
- Read the metrics the agent exposes with `kubectl -n kube-system port-forward ds/cilium 9962`.
- List the Hubble metrics settings in `kubectl -n kube-system get configmap cilium-config -o yaml`.
