---
draft: true
---
# Cilium Ingress In Depth

A first Ingress only needs a host, a path and a backend. A production Ingress also needs encrypted traffic, a clear rule for which request path matches which backend, a decision about how many entry points the cluster has, and a way to reach the entry point from outside the cluster. The Cilium Ingress controller handles each of these through Helm values on the Cilium installation and annotations on each Ingress.

Keep one sentence in mind for this module: **the Cilium operator reads each Ingress, builds one Envoy listener configuration and one Service for it (or one shared Service for all), and every setting you add is either a Helm value for all Ingress resources or an annotation for one Ingress.** You will compare the two load balancer modes, test the three path types, terminate TLS with a Secret and change how the entry point is exposed.

The module has four parts. **Shared And Dedicated Entry Points** creates several Ingress resources and shows which Service each one uses and how to change the Service type. **Host And Path Matching** tests the `Exact`, `Prefix` and `ImplementationSpecific` path types and shows how Envoy picks one rule. **TLS Termination With A Secret** stores a certificate in a Secret, serves HTTPS and explains the redirect from HTTP. **Reaching The Entry Point From Outside** covers gRPC backends, traffic policy and host network mode.

## Learning objectives

After this module you can:

- Explain the difference between the `dedicated` and `shared` load balancer modes and set the mode for one Ingress with an annotation.
- Set the Service type of the Ingress entry point and say which Helm values control it.
- Write rules with `Exact`, `Prefix` and `ImplementationSpecific` path types and predict which rule matches a request.
- Create a TLS Secret, add a `tls` entry to an Ingress and test HTTPS with `curl --resolve`.
- Explain the default redirect from HTTP to HTTPS and how to switch it off for one Ingress.
- Name the Service port setting that makes Cilium use HTTP/2 without TLS for a gRPC backend.

## Before you start

You need the basics of the `Ingress` resource: `ingressClassName`, rules, host and path. You also need to know what a Kubernetes Secret and a TLS certificate are, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement, the Cilium Ingress controller in `dedicated` mode and the Gateway API controller. A kind cluster has no cloud load balancer, so you reach each entry point through the node IP address and the node port from the `shuttle` pod. `openssl` must be available in your terminal to make a certificate.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl`, used to send test requests |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

No `Ingress` exists yet. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
