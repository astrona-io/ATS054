---
draft: true
---
# The Cilium Ingress Controller

A Service of type `ClusterIP` is reachable only from inside the cluster. An Ingress adds one shared HTTP entry point in front of many Services and chooses the Service by host name and path. This part enables the Cilium Ingress controller, creates one Ingress and follows a request from the client to the pod. It ends with the difference between the dedicated and the shared load balancer mode.

## What an Ingress is and who acts on it

An **Ingress** is a Kubernetes resource that lists HTTP routing rules: a host name, a path and a backend Service. The resource does nothing alone. An **Ingress controller** is a program that watches Ingress resources and configures a proxy to follow the rules. An **IngressClass** names the controller that owns an Ingress, and the field `spec.ingressClassName` on the Ingress selects it.

Cilium ships an Ingress controller inside the Cilium operator. Cilium creates the IngressClass named `cilium` when the controller is enabled. The proxy is Envoy, an HTTP proxy that Cilium runs on each node in the `cilium-envoy` DaemonSet. Check that the class exists:

<!-- astrona:playground:renew -->

```sh
kubectl get ingressclass
```

The list contains an IngressClass named `cilium` with the controller `cilium.io/ingress-controller`.

## The Helm values behind it

The controller is off by default. Two prerequisites apply: kube-proxy replacement must be on (`kubeProxyReplacement=true`) and the Layer 7 (L7) proxy must be on (`l7Proxy=true`, which is the default). The playground installed Cilium with these values:

```text
kubeProxyReplacement=true
ingressController.enabled=true
ingressController.loadbalancerMode=dedicated
```

On an existing installation, you set the values with `helm upgrade` and then restart `deployment/cilium-operator` and `daemonset/cilium`, because the agents read the setting at start. Confirm what the running agent uses:

```sh
kubectl -n kube-system get configmap cilium-config -o yaml | grep -i ingress
```

Look for the key `enable-ingress-controller` with the value `"true"`.

## Create the first Ingress

Save this as `ingress-scout.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scout
  namespace: starfleet
spec:
  ingressClassName: cilium
  rules:
    - host: scout.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scout
                port:
                  number: 80
```

The rule says that a request for the host `scout.example.com` with any path that starts with `/` goes to port 80 of the Service `scout`. Apply it:

```sh
kubectl apply -f ingress-scout.yaml
```

Then check what the Cilium operator created in response:

```sh
kubectl -n starfleet get ingress scout
kubectl -n starfleet get service
kubectl -n starfleet get ciliumenvoyconfig
```

The Service list now holds a Service named `cilium-ingress-scout` of type `LoadBalancer`. The operator created it, not you. A `CiliumEnvoyConfig` object holds the Envoy listener and route configuration that the operator built from your Ingress. On kind, the Ingress and the Service show no external address, because no component answers the load balancer request.

## Follow one request

The Service `cilium-ingress-scout` also has a node port, which every node opens. Read the node port and the worker node address, then send a request from the `shuttle` pod:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: scout.example.com' "http://$NODE_IP:$NODE_PORT/"
```

The reply is the JSON document of podinfo, with a `message` field that names podinfo. The `Host` header matters: Envoy picks the route from it. Send the same request with the host `other.example.com` and the reply is a `404`, because no rule matches that host:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -H 'Host: other.example.com' "http://$NODE_IP:$NODE_PORT/"
```

The path of the request has these steps:

```mermaid
flowchart LR
  C["shuttle"] -->|"node IP and node port"| E["Envoy on node"]
  E -->|"Host: scout.example.com"| S["Service: scout"]
  S --> P["scout pod"]
```

The diagram shows that the client talks to Envoy, not to the pod. Envoy matches the host and path, then sends the request to a pod behind the Service `scout`. Cilium eBPF programs on the node steer the packet that arrives on the node port to the Envoy listener.

## Dedicated and shared load balancer mode

The value `ingressController.loadbalancerMode` sets how many entry points Cilium creates. In `dedicated` mode, each Ingress gets its own Service, as you saw with `cilium-ingress-scout`. Each Ingress has its own address, and one Ingress cannot collide with another. In `shared` mode, all Ingress resources use one Service, `cilium-ingress` in `kube-system`, and one address. Shared mode uses fewer addresses, but all Ingress resources then share one routing table, so two Ingress resources with overlapping paths can conflict.

You can override the mode for a single Ingress with the annotation `ingress.cilium.io/loadbalancer-mode`, set to `dedicated` or `shared`. Changing the mode of an existing Ingress can give it a new address and break connections that are open.

## Common pitfalls

> [!WARNING]
> Without `kubeProxyReplacement=true` the Ingress controller does not work. An Ingress without `ingressClassName: cilium` is ignored by Cilium unless the controller was installed as the default controller. A Service of type `LoadBalancer` that shows `<pending>` on kind is normal: use the node IP and the node port. A request with a wrong `Host` header gets a `404`, which proves Envoy answered and no rule matched.
