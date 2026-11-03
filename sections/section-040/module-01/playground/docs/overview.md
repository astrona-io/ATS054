# Overview: Encrypting Traffic In Transit With Cilium (Playground)

This is a playground, not a lab. It starts a cluster with Cilium and the example workloads, and then waits. There is no task, no `astrona submit` and no pass or fail. Look at the encryption, change settings, run `astrona destroy`, and start over.

## What is in the box

- A `kind` cluster with one control-plane node and one worker node. `kubectl` already points at it.
- Cilium with kube-proxy replacement, WireGuard encryption (`encryption.type=wireguard`), Hubble, and mutual authentication with a SPIRE server and agents in the namespace `cilium-spire`. SPIRE uses no persistent storage.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` | podinfo, Service port 80, pod port 9898 |
  | `starfleet` | `probe` | go-httpbin, Service port 80, pod port 8080 |
  | `starfleet` | `shuttle` | A pod with `curl` |
  | `outpost` | `drifter` | A pod with `curl` in another namespace |

- No `CiliumNetworkPolicy` exists.

## Helpers

Paste these once in each new terminal. `agent` runs a command in the Cilium agent of the node you pick, and `from_shuttle` prints the HTTP status code of a request from `shuttle`.

```sh
agent() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- "$@"; }
from_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}\n' "$@"; }
```

Use them like this: `agent cilium-dbg status` and `from_shuttle http://scout.starfleet.svc/`.

## Practice tasks

- Read the encryption line of `agent cilium-dbg status` and the annotations of the two nodes.
- Find which node each pod runs on with `kubectl get pods -A -o wide`, and send a request between two pods on different nodes.
- Read `kubectl -n kube-system get configmap cilium-config -o yaml` and find the keys for encryption and for node encryption.
- Create a Secret in the format of `cilium-ipsec-keys` under another name, then delete it.
- Apply a policy with `authentication.mode: required` and send a request that it covers.
