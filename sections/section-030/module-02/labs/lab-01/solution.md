# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Read the Ingress

```sh
kubectl -n starfleet get ingress fleet -o yaml
```

There are two paths with the type `Prefix`, one host and no TLS. Each maps to a rule in the route: `Prefix` becomes `PathPrefix`, the host becomes `hostnames`, and the Service port becomes the `port` of a `backendRef`.

## Step 2: Create the Gateway and the route

Save this as `gateway.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: fleet
  namespace: starfleet
spec:
  gatewayClassName: cilium
  listeners:
    - name: web
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: fleet
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
  hostnames:
    - fleet.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /probe
      backendRefs:
        - name: probe
          port: 80
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: scout
          port: 80
```

```sh
kubectl apply -f gateway.yaml
```

## Step 3: Test the Gateway, then delete the Ingress

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: fleet.example.com' "http://$NODE_IP:$NODE_PORT/"
kubectl -n starfleet delete ingress fleet
```

The first reply is the podinfo JSON of `scout`. Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-02/labs/lab-01 --keep
```

## Why this is the answer

Both objects describe the same routes, so you can run them side by side, test the new entry point with a `Host` header, and remove the old one at the end. The Gateway has its own Service and address, so nothing changes for clients until you move the DNS name.
