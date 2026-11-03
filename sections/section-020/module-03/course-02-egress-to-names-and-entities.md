---
draft: true
---
# Egress To Names And Entities

Controlling what enters a pod is half of the job. A pod that is compromised will try to call out. This part controls egress to DNS names outside the cluster and to groups of endpoints called entities.

## Entities

An **entity** is a name for a group of endpoints that you cannot list by label. The ones you will use:

- `world`: everything outside the cluster.
- `cluster`: everything inside the cluster.
- `host`: the node the pod runs on.
- `remote-node`: the other nodes of the cluster.
- `kube-apiserver`: the Kubernetes API server.
- `ingress`: the Envoy proxy that handles Gateway and Ingress traffic.

Use them in `toEntities` for egress and `fromEntities` for ingress. A rule that lets `shuttle` reach the API server looks like this:

```yaml
  egress:
    - toEntities:
        - kube-apiserver
```

## Egress to a DNS name

IP addresses of internet services change, so write the name. The field `toFQDNs` allows egress to the addresses that a name resolves to. It needs two rules: one that allows and **inspects** the DNS lookups, and one that allows the traffic to the names. Save this as `shuttle-fqdn.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: shuttle-fqdn
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: shuttle
  egress:
    - toEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: kube-system
            k8s-app: kube-dns
      toPorts:
        - ports:
            - port: "53"
              protocol: ANY
          rules:
            dns:
              - matchPattern: "*"
    - toFQDNs:
        - matchName: "example.com"
      toPorts:
        - ports:
            - port: "443"
              protocol: TCP
```

<!-- astrona:playground:renew -->

```sh
kubectl apply -f shuttle-fqdn.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 8 -o /dev/null -w '%{http_code}\n' https://example.com
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 8 -o /dev/null -w '%{http_code}\n' https://www.cilium.io
```

The first request reaches the name that the policy allows, if the cluster has internet access. The second prints `000`: the name is not allowed. The rule works because Cilium sees the DNS answer in its DNS proxy and allows the addresses in it for the lifetime of the record.

## Patterns

`matchName` is an exact name. `matchPattern` accepts `*` as a wildcard, for example `*.example.com`. Keep patterns narrow, because a broad pattern defeats the purpose.

## Common pitfalls

> [!WARNING]
> `toFQDNs` does nothing without a DNS rule that inspects the lookups, so the pod must resolve names through the Cilium DNS proxy. A pod that has a cached or hard-coded IP address will not be matched, because the proxy never saw the lookup. A `matchPattern` of `*` allows every name.
