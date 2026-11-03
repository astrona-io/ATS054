# Overview: Operate IPsec Encryption (Playground)

This is a playground, not a lab. It starts a cluster with Cilium and the example workloads, and then waits. There is no task, no `astrona submit` and no pass or fail. Look at the encryption, change settings, run `astrona destroy`, and start over.

## What is in the box

- A `kind` cluster with one control-plane node and one worker node. `kubectl` already points at it.
- Cilium with kube-proxy replacement and no encryption, so you can build and read an IPsec key Secret without changing the data path.
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

- Create a Secret `demo-ipsec-keys` in `kube-system` with the key line `1+ rfc4106(gcm(aes)) <40 hex characters> 128`, read it back and delete it.
- Generate a key with `dd if=/dev/urandom count=20 bs=1 2>/dev/null | xxd -p -c 64` and count its characters.
- Read `agent ip xfrm state` and `agent ip xfrm policy` and note that both are empty without IPsec.
- Read the `cilium-config` keys and find the ones for encryption.
- Write the Helm values you would set to use IPsec with your Secret.
- Make a line with a wrong key length and say which field the agent would reject.
