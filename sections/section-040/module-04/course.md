---
draft: true
---
# Mutual Authentication In Practice

Encryption hides traffic, but it does not say who is on the other end. Mutual authentication does: before traffic between two workloads is allowed, both sides prove their identity. Cilium uses SPIFFE identities and a SPIRE installation for this. This module works through it with a running cluster.

Keep one sentence in mind for this module: **a policy rule with `authentication.mode: required` accepts traffic only after the agents of both nodes have checked the identities of the two workloads with SPIRE.** You will look at the SPIRE parts, write the rule, read the authentication state and learn what the feature does not do.

The module has four parts. **The SPIRE Components** names the server, the agents and the identities. **Require Authentication In A Policy** shows the rule and the order of events. **Observe And Verify** reads the state. **Limits And Troubleshooting** says what the feature does not cover and where it fails.

## Learning objectives

After this module you can:

- Name the SPIRE parts and the identity of a workload.
- Write a policy rule that requires authentication.
- Read the authentication state of an agent.
- Say what mutual authentication does not do, and troubleshoot it.

## Before you start

You need the policy basics from the first module of the section on service mesh and the idea of identity from the first module of this section.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, WireGuard encryption, Hubble, and mutual authentication with a SPIRE server and agents in `cilium-spire`.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80, pod port 9898 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
