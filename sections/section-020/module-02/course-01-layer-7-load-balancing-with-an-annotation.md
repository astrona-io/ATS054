---
draft: true
---
# Layer 7 Load Balancing With An Annotation

The simplest way to use the Cilium Envoy proxy for traffic management is one annotation on a Service. This part explains the problem it solves and turns it on.

## Per connection and per request

Kernel load balancing picks a backend when a connection opens. A client that opens one HTTP/2 or gRPC connection and sends many requests over it talks to one pod for the whole life of the connection, even when ten pods exist. Layer 7 load balancing reads each request and picks a backend for it. The price is one more hop through Envoy on the node, so use it where per-request decisions matter.

## Prerequisite in Helm

Layer 7 load balancing for Services needs the Envoy proxy and the Helm value `loadBalancer.l7.backend=envoy`. Check it in your playground:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get configmap cilium-config -o yaml | grep -i -E 'envoy|loadbalancer-l7'
```

The output lists settings for Envoy and a Layer 7 load balancer backend. Without it, the annotation is ignored.

## Create a Service and annotate it

Scale `probe` to three pods so there is something to balance, and create a Service in front of it:

```sh
kubectl -n starfleet scale deploy/probe --replicas=3
kubectl -n starfleet rollout status deploy/probe
kubectl -n starfleet create service clusterip probe-lb --tcp=80:8080
kubectl -n starfleet set selector service probe-lb app=probe
```

Now turn on Layer 7 load balancing:

```sh
kubectl -n starfleet annotate service probe-lb service.cilium.io/lb-l7=enabled
```

Cilium sees the annotation and creates an Envoy configuration for this Service. The Service keeps its name, its ClusterIP and its port, so clients change nothing.

## Prove it

Send 12 requests to the `/hostname` endpoint of go-httpbin, which prints the name of the pod that answered, and count the pods:

```sh
for i in $(seq 1 12); do kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 http://probe-lb.starfleet.svc/hostname; echo; done | sort | uniq -c
```

The count shows several pod names with similar numbers. Each request is balanced on its own, even though `curl` opens a new connection every time here. To see the difference you would need one connection with many requests, for example with `curl` and two URLs on the same command line.

## Remove it

Remove the annotation with `kubectl -n starfleet annotate service probe-lb service.cilium.io/lb-l7-`. The Service goes back to kernel balancing, and the Envoy configuration for it is removed.

## Common pitfalls

> [!WARNING]
> The annotation does nothing when the Helm value for the Layer 7 backend is not set. Layer 7 balancing adds latency compared with the kernel path, so do not enable it for every Service. A Service in the Envoy path is subject to the Envoy limits, such as the supported protocols.
