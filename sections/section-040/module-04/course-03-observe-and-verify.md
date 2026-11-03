---
draft: true
---
# Observe And Verify

A request that works is not proof that authentication happened. Read the state of the agent and of SPIRE.

## The authentication table

Each Cilium agent keeps a table of authenticated pairs in a BPF map. List it:

<!-- astrona:playground:renew -->

```sh
agent() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- "$@"; }
agent cilium-dbg bpf auth list
```

After a request from `shuttle` to `scout` under the policy of the previous part, the table shows an entry for the pair of identities, the type of authentication and the time when the entry expires. An empty table after traffic means authentication did not run: check that the rule has the field, and that the policy is applied to the right pods.

## The registration entries

The SPIRE server lists the entries that the operator created:

```sh
kubectl -n cilium-spire exec statefulset/spire-server -c spire-server -- /opt/spire/bin/spire-server entry show
```

Each entry has a SPIFFE ID, a parent (the node agent) and selectors that tie it to a workload. The output is long on a big cluster, so pipe it to `grep` to find a name.

## The flows

Hubble shows a drop with a reason about authentication when traffic is dropped because the pair is not authenticated yet:

```sh
agent hubble observe --verdict DROPPED --last 20
```

A few such drops right after a policy is applied are normal. Drops that continue point at a fault: the handshake fails.

## Compare with and without

Delete the policy, send a request, then apply the policy and send the same request while you watch the table and the flows. You see the difference between plain allow and allow with authentication: the request is the same, but the table gets an entry.

## Common pitfalls

> [!WARNING]
> Do not read an expired or missing table entry as a failure of the policy. Entries are created on demand and expire. Send a request and read the table again.
