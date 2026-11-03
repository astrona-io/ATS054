---
draft: true
---
# What A Service Mesh Does

A service mesh sits in the path of the requests between services. This part lists the use cases a mesh covers, sorts them by the layer of the network they need, and shows which Cilium component handles each group. It ends with a decision rule: when you need a Layer 7 proxy and when the kernel is enough.

## The three groups of use cases

The use cases fall into three groups. Each group answers a question about the traffic between two services.

- **Traffic management** answers: where does this request go? Examples are routing by path or header, splitting traffic by weight between two versions, retries and timeouts.
- **Security** answers: who may send this request? Examples are allowing only named clients, allowing only some HTTP methods and paths, and encrypting the traffic between nodes.
- **Observability** answers: what happened to this request? Examples are the source and destination of each request, the HTTP status code, the latency, and the count of denied requests.

Without a mesh, every service implements these functions in its own code or library, in every language the company uses. With a mesh, the infrastructure implements them once, and a platform team changes the rules without a new release of each service.

## Where the work happens

A request between two pods can be handled at three points in Cilium.

The first point is **eBPF** (extended Berkeley Packet Filter): small programs that Cilium loads into the Linux kernel. They run on every packet at the network interface of the pod and the node. eBPF programs enforce Layer 3 and Layer 4 rules, such as "pods with the label `app=shuttle` may connect to TCP port 8080 of pods with the label `app=probe`". They also do Service load balancing when kube-proxy replacement is on.

The second point is the **Cilium agent**, a pod that runs on every node (the `cilium` DaemonSet). It reads the policies and the Kubernetes objects, gives each pod an identity, and writes the rules into eBPF maps. A **Cilium identity** is a number that stands for a set of pod labels. Rules refer to identities, not to IP addresses.

The third point is the **Envoy proxy**, which runs on every node in the `cilium-envoy` DaemonSet. Envoy understands HTTP. It parses each request and applies Layer 7 rules, and it produces HTTP metadata such as the method, the path and the status code. eBPF sends a connection to Envoy only when a rule for that pod and port needs Layer 7 processing.

Look at these components in the playground:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get pods -l k8s-app=cilium
kubectl -n kube-system get pods -l k8s-app=cilium-envoy
kubectl -n starfleet get pods
```

You see one `cilium` pod and one `cilium-envoy` pod for each node. The pods in `starfleet` show `1/1` in the `READY` column, which means each pod has only its application container and no sidecar proxy.

## Use cases mapped to Cilium features

| Use case | Layer | Cilium feature | Handled by |
| --- | --- | --- | --- |
| Allow only some pods to connect to a port | 3 and 4 | `CiliumNetworkPolicy` with `fromEndpoints` and `toPorts` | eBPF in the kernel |
| Allow only some HTTP methods and paths | 7 | `CiliumNetworkPolicy` with `rules.http` | Envoy on the node |
| Route by host, path or header, split by weight | 7 | Gateway API and Ingress | Envoy on the node |
| Encrypt traffic between nodes | 3 | WireGuard or IPsec | Linux kernel |
| See sources, destinations, verdicts, HTTP details | 3 to 7 | Hubble | eBPF and Envoy report flows |

The table shows that Cilium delivers a use case with the cheapest component that can do it. A rule on a port stays in the kernel. A rule on an HTTP path goes through Envoy.

## Check a Layer 4 rule first

A Layer 3 and Layer 4 rule shows the first group of behaviour without a proxy. Save this as `policy-probe-l4.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-l4
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
```

The policy selects the pods with the label `app=probe`. It allows connections to TCP port 8080 only from pods with the label `app=shuttle` in the same namespace. Apply it:

```sh
kubectl apply -f policy-probe-l4.yaml
```

Then send a request to the Service `probe` from `shuttle` and from `drifter`:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

The first request returns `200`. The second request prints `000` after five seconds, because the kernel drops the connection packets from `drifter` and `curl` times out. No proxy answered the second request, and no HTTP status exists for it. Delete the policy to leave the playground clean:

```sh
kubectl -n starfleet delete ciliumnetworkpolicy probe-l4
```

## When you need a mesh and when you do not

Choose the least that meets the need. If you only need to control which workloads connect to which ports, and to encrypt node traffic, Layer 3 and Layer 4 policy and transparent encryption are enough. If you need decisions on HTTP methods and paths, routing by header or split traffic, you need Layer 7 processing. If you need an identity per workload checked in a handshake, you need mutual authentication. Each step adds cost: a Layer 7 rule sends traffic through Envoy, which adds latency and CPU use on the node.

## Common pitfalls

> [!WARNING]
> A mesh does not fix an application that ignores errors. A policy on a pod changes that pod from "allow all" to "deny all except the listed rules" for the direction it names, so a missing rule blocks traffic that worked before. The kernel drop gives a timeout, not a status code, so a timeout and a `403` mean different components acted.
