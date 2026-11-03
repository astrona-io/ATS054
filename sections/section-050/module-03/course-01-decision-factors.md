---
draft: true
---
# Decision Factors

"Which mesh design should we use?" has no single answer. Ask a short list of questions about the workload and the team, and write the answers down.

## The questions

| Question | Points to sidecarless | Points to a sidecar |
| --- | --- | --- |
| Is most traffic Layer 3 and Layer 4? | Yes: the kernel handles it | No |
| How dense are the nodes? | Many small pods | Few big pods |
| Who owns the proxy upgrade? | A platform team | Each application team |
| Do teams need a different proxy version or filter? | No | Yes |
| Must pod specs stay unchanged? | Yes | No |
| Is there a rule about per-pod isolation of the proxy? | No | Yes |
| Does the application depend on features that only the existing mesh offers? | No | Yes |

## Reading the table

Count the rows that apply and note the ones that are firm requirements, not preferences. A firm requirement for a per-pod proxy version settles the question for that workload. A table with mostly preferences means the cost and operation questions decide.

## One cluster can have both

A cluster is not forced to one design. A workload with a firm requirement can keep a sidecar while the rest moves. What you want to avoid is two meshes that enforce overlapping rules without a plan, because a request then passes two sets of policies and failures are hard to place.

## Write the decision

Keep a short record for each workload: the answers to the questions, the choice, the date and the person who owns it. A record turns a debate into something you can review when the facts change.

<!-- astrona:playground:renew -->

```sh
kubectl get namespaces --show-labels
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CONTAINERS:.spec.containers[*].name | grep -E 'starfleet|outpost'
```

The labels and the containers are the first facts for the table: which namespaces use injection, and which pods carry a proxy.

## Common pitfalls

> [!WARNING]
> Do not choose by name or by trend. A design that is right for a large platform team may be wrong for a team of three. Decide per workload, from the answers, and review the decision when the platform changes.
