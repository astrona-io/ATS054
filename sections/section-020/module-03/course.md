---
draft: true
---
# Security Use Cases With Cilium

Security is the main reason many teams adopt a service mesh. The questions are always the same: who may talk to whom, who may leave the cluster and to where, and how does a service know that its caller is who it says it is. Cilium answers them with identities and policies, without a sidecar in every pod.

Keep one sentence in mind for this module: **a pod becomes restricted in a direction as soon as one policy selects it and has a section for that direction, and everything that no rule allows is dropped.** You will build default deny, allow calls by identity, allow calls to names outside the cluster, use entities, and read how mutual authentication adds proof of identity.

The module has four parts. **Default Deny And Identity-Based Rules** restricts a pod and allows callers by label. **Egress To Names And Entities** controls what leaves the cluster. **Deny Rules And Policy Precedence** adds explicit denies. **Mutual Authentication In Policies** shows how a rule can require a verified identity.

## Learning objectives

After this module you can:

- Explain when a pod enters default deny and in which direction.
- Allow callers by label, namespace and port with a `CiliumNetworkPolicy`.
- Allow egress to DNS names with `toFQDNs` and to groups with entities.
- Write explicit deny rules and predict that deny wins.
- Say what `authentication.mode: required` asks for and what it needs.

## Before you start

You need pod labels, namespaces and a first `CiliumNetworkPolicy` from the Layer 7 module.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Envoy proxy and Hubble. No policy exists yet.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 (pod port 9898) |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 (pod port 8080) |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
