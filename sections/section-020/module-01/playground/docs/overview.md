# Overview: Service Mesh Use Cases With Cilium (Playground)

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

- Allow only `GET /get` to `probe` from `shuttle`. Check `/uuid` (403) and `drifter` (000).
- Write a policy for `scout` that allows `GET` on every path from both clients and denies `POST`.
- Add a header condition to one rule, then send the request with and without the header.
- Find the `DROPPED` flows for `drifter` with `flows --verdict DROPPED`, and the HTTP flows with `flows --protocol http`.
- Delete every policy and confirm that all requests return 200 again.
