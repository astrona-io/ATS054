---
draft: true
---
# Operate WireGuard Encryption

Turning on WireGuard is one setting. Running it is a different job: you must prove that it is active, know what it covers, keep the network open for it and find the cause when a peer is missing. This module is about that second job.

Keep one sentence in mind for this module: **the agent status line and the node annotations tell you whether encryption is active, and a missing peer almost always means a blocked UDP port or a missing kernel feature.** You will read the status, choose between pod-to-pod and node-to-node encryption, plan ports and MTU, and follow a short path to find a fault.

The module has four parts. **Verify That WireGuard Is Active** reads the status line, the device and the keys. **Node Encryption And Strict Mode** covers what the default setting leaves open. **Ports, MTU And Overhead** lists what the network must allow. **Troubleshoot WireGuard** gives an order of checks.

## Learning objectives

After this module you can:

- Read the agent status and the node annotations to confirm WireGuard.
- Say what node encryption and strict mode add.
- Name the UDP port and explain the MTU effect.
- Follow an ordered path to find why a peer is missing.

## Before you start

You need the idea of transparent encryption from the previous module and `kubectl exec`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, WireGuard encryption, Hubble, and mutual authentication with SPIRE.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl` |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

`kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
