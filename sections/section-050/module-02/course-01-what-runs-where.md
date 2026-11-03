---
draft: true
---
# What Runs Where

Make a map of the cluster before you reason about it. In a sidecarless Cilium cluster four kinds of parts matter, and each has a known place.

## The map

| Part | Kind | Count | Does |
| --- | --- | --- | --- |
| `cilium` | DaemonSet in `kube-system` | one per node | Loads the eBPF programs, enforces policy, keeps identities |
| `cilium-envoy` | DaemonSet in `kube-system` | one per node | Runs the Envoy proxy for Layer 7 rules, ingress and Gateway |
| `cilium-operator` | Deployment in `kube-system` | one or a few | Allocates IP ranges, manages CRDs and Gateway objects |
| Application pods | Deployments | as you scale | Run the application only |

Two of these four scale with the node count. The application pods do not carry a proxy.

## Look at it

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get daemonset
kubectl -n kube-system get pods -l k8s-app=cilium -o wide
kubectl -n kube-system get pods -l k8s-app=cilium-envoy -o wide
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CONTAINERS:.spec.containers[*].name | grep -E 'starfleet|outpost'
```

You see one `cilium` pod and one `cilium-envoy` pod on each node, and one container in each application pod.

## Which traffic uses which part

- **Layer 3 and Layer 4**: handled in the kernel by the eBPF programs. The proxy is not involved.
- **Layer 7 rules, ingress and Gateway traffic**: the eBPF program redirects the packets to the Envoy proxy on the same node.
- **Identity and policy decisions**: made in the kernel from the identity of the pods, not from an address.

## Check that no hidden proxy exists

A sidecar mesh adds a mutating webhook that injects the proxy into new pods:

```sh
kubectl get mutatingwebhookconfigurations
```

A sidecarless cluster has no webhook with a mesh name such as `istio` or `linkerd`. Cilium itself does not inject containers into your pods.

## Common pitfalls

> [!WARNING]
> Do not conclude that the cluster is sidecarless from one listing. Look at the containers of the pods in the namespaces you care about, the webhooks, and the labels on the namespaces. A leftover injection label or webhook from an old mesh can still add proxies to new pods.
