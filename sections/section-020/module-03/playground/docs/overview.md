# Overview: Security Use Cases With Cilium (Playground)

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

- Apply a policy with an empty `ingress` section to `probe` and see all callers blocked.
- Allow only `shuttle` to call `probe`, and test from `drifter`.
- Allow egress to a name with `toFQDNs` and test a name that is not allowed.
- Use the entity `world` and the entity `kube-apiserver` in an egress rule.
- Read the verdict of each test with `hubble observe --verdict DROPPED`.
- Delete the policy and check that traffic flows again.
