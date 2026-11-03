---
draft: true
---
# Security Boundaries And Trade-offs

A shared proxy changes the security picture. Some things get better and some need attention.

## What gets better

- **No injection in your pods.** A mutating webhook that changes every pod is a powerful control point and a possible attack path. Without it, pods stay as you wrote them.
- **Identity in the kernel.** The identity of a pod is a label-based number that the kernel uses for the policy. It does not depend on an address or on a certificate held by a proxy in the pod.
- **No bypass inside the pod.** A sidecar can be bypassed by an application that sends traffic outside the redirect rules. In the sidecarless design the redirect is made on the node, outside the pod.

## What needs attention

- **A shared proxy sees the traffic of many pods.** The Envoy of a node handles requests of all pods that use Layer 7 rules on that node. A bug in the proxy affects all of them, and the proxy is a high-value target. Keep it updated and limit access to the node.
- **Per-pod proxy settings are not possible.** A sidecar can have a setting for one workload. The node proxy uses the settings from the policies and from Cilium, so a special case needs a policy, not a proxy flag.
- **Encryption and authentication come from other features.** Traffic between nodes is encrypted with WireGuard or IPsec, and the identity of workloads is proved by mutual authentication. They are not part of the proxy.

## Choosing the boundary

| If you need | A sidecar design gives | The sidecarless design gives |
| --- | --- | --- |
| A different proxy version for one team | Easy | Not possible per pod |
| Lowest cost at high pod density | No | Yes |
| No change to pod specs | No | Yes |
| Isolation of a proxy bug to one pod | Yes | No, to one node |

Neither design is better for every workload. The choice depends on which row matters to you.

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get pods -l k8s-app=cilium-envoy -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.hostNetwork}{"\n"}{end}'
```

The Envoy pods run in the host network of their node. That is how they serve the pods of the node, and it is why access to the node matters.

## Common pitfalls

> [!WARNING]
> Do not describe the sidecarless design as "more secure" or "less secure" without saying in what way. It moves the proxy from the pod to the node, which removes some risks and adds others. Say which risk you mean.
