---
draft: true
---
# Read Flows With The Hubble CLI

Hubble is the observability layer of Cilium. Each Cilium agent records the flows of the pods on its node, and Hubble Relay gathers them from all nodes, so one command shows the whole cluster. This part reaches Hubble and reads a flow field by field.

## Reach Hubble

The `hubble` CLI talks to Hubble Relay. Forward the relay port with the `cilium` CLI, or with `kubectl`, and check the status:

<!-- astrona:playground:renew -->

```sh
cilium hubble port-forward &
hubble status
```

If you do not have the CLIs, run the command inside an agent pod instead: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --last 5`. This shows only the flows of that node.

## Generate and read a flow

Send a request, then read the last flows of the namespace:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://scout.starfleet.svc/
hubble observe --namespace starfleet --last 10
```

A line looks like this:

```text
Nov  3 10:00:01.123: starfleet/shuttle-7d9:41234 (ID:12345) -> starfleet/scout-5f4:9898 (ID:23456) to-endpoint FORWARDED (TCP Flags: SYN)
```

Read it from left to right:

- the time of the event;
- the **source**: namespace, pod name, port and the numeric security **identity** in brackets;
- an arrow and the **destination** in the same form;
- the **type** of event, such as `to-endpoint`, `to-stack` or `to-proxy`;
- the **verdict**: `FORWARDED`, `DROPPED`, `AUDIT` or `REDIRECTED`;
- extra detail, such as the TCP flags.

The names show the pods and not only IP addresses, because Cilium knows which pod owns each address.

## Follow live traffic

Add `--follow` to stream flows as they happen, and send requests from another terminal. This is the fastest way to see whether a request leaves the client and whether it arrives.

## DNS is visible too

Cilium sees DNS lookups at the agent. Run `hubble observe --protocol dns --namespace starfleet` and send a request that uses a name. The flow shows the query name and the answer. A failing lookup is a common cause of "the service is down".

## Common pitfalls

> [!WARNING]
> `hubble observe` shows a limited window of recent flows kept in memory on each node, so old events are gone. A flow is recorded at the node of the pod, so an agent-only command shows only the flows of that node. If `hubble status` says the relay is not reachable, the port forward is not running.
