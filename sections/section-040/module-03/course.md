---
draft: true
---
# Operate IPsec Encryption

IPsec is the older of the two encryption modes in Cilium. It uses the kernel's own IPsec stack, which many security teams know and some standards require. It also needs more care than WireGuard: you create and rotate the keys yourself.

Keep one sentence in mind for this module: **IPsec in Cilium is driven by one Secret with the keys, and the kernel holds the state that the agents build from it, so you manage the Secret and read the kernel to know what runs.** You will build the key line, plan a rotation, read the kernel state and compare IPsec with WireGuard.

The module has four parts. **How Cilium Uses IPsec** explains the kernel objects. **The Key Secret** shows the format and how to create it. **Rotate The Keys** gives a safe order. **Read The State And Choose A Mode** covers the status output, common faults and a comparison with WireGuard.

## Learning objectives

After this module you can:

- Say what the kernel holds when IPsec runs.
- Write a valid key line and create the Secret.
- Rotate a key without dropping traffic.
- Read the IPsec status and pick between IPsec and WireGuard.

## Before you start

You need the idea of transparent encryption from the first module of this section.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement and no encryption, so you can build the Secret and read the kernel without changing the data path.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
