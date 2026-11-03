---
draft: true
---
# Route External Traffic With Cilium Ingress And Gateway API

A Kubernetes cluster runs its workloads on a private pod network. Clients outside that network, and teams that want one entry point for many services, need a component that accepts HTTP requests and forwards each one to the right Service. Kubernetes has two APIs for this: the Ingress resource and the Gateway API. Cilium implements both, and both use the same Envoy proxy on each node to do the forwarding.

Keep one sentence in mind for this module: **an Ingress or a Gateway only declares the routing; the Cilium operator turns it into a Service and Envoy configuration, and the Envoy proxy on the node forwards the request to the backend.** You will enable both controllers, send a request to each, read the resources and status conditions that Cilium creates, and fix a route that does not attach.

The module has three parts. **The Cilium Ingress Controller** enables the controller, creates an `Ingress` and follows one request from the client to the pod. **Gateway API Resources In Cilium** creates a `Gateway` and an `HTTPRoute` and shows which object each team owns. **Matching, Splitting And Debugging Routes** adds path and header rules, splits traffic by weight and reads status conditions to find out why a route does not work.

## Learning objectives

After this module you can:

- Enable the Cilium Ingress controller and the Cilium Gateway API controller, and name the Helm values and prerequisites each one needs.
- Write an `Ingress` with host and path rules for the `cilium` ingress class, and explain what the dedicated and shared load balancer modes change.
- Write a `Gateway` and an `HTTPRoute` for the `cilium` `GatewayClass`.
- Explain which Cilium component creates the Service and the Envoy configuration for each resource.
- Route by path and header, split traffic by weight and send a request to each result from inside the cluster.
- Read the `Accepted` and `ResolvedRefs` conditions of an `HTTPRoute` and fix the field that causes a failure.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. You also need to know that a Service of type `LoadBalancer` asks the environment for an external address.

Your playground is a `kind` cluster with one control-plane node and one worker node, running Cilium with kube-proxy replacement. The Gateway API custom resource definitions (CRDs) are already installed. The Cilium Ingress controller and the Cilium Gateway API controller are both enabled. A kind cluster has no cloud load balancer, so a `LoadBalancer` Service never gets an external address. You reach the entry point through the node IP address and the node port instead, from the `shuttle` pod.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` Deployment and Service | A podinfo web service on Service port 80 |
| `starfleet` | `probe` Deployment and Service | A go-httpbin web service on Service port 80 |
| `starfleet` | `shuttle` Deployment | A client pod with `curl`, used to send test requests |
| `outpost` | `drifter` Deployment | A second client pod with `curl`, in another namespace |

No `Ingress`, `Gateway` or `HTTPRoute` exists yet. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
