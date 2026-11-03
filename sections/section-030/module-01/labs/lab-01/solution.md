# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Read why the route is rejected

```sh
kubectl -n starfleet get httproute scout -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0]}{"\n"}'
```

The `Accepted` condition is `False` with the reason `NotAllowedByListeners`. The listener has no `allowedRoutes`, so the default `from: Same` accepts only the namespace `edge`.

## Step 2: Allow namespaces with a label

Save this as `gateway-edge.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: edge-gw
  namespace: edge
spec:
  gatewayClassName: cilium
  listeners:
    - name: web
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              access: gateway
```

Apply it:

```sh
kubectl apply -f gateway-edge.yaml
```

## Step 3: Label the namespace of the route

```sh
kubectl label namespace starfleet access=gateway
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-01/labs/lab-01 --keep
```

## Step 4: Test by hand

```sh
kubectl -n starfleet get httproute scout -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}{"\n"}'
kubectl -n outpost get httproute outpost-probe -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}{"\n"}'
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n edge get service cilium-gateway-edge-gw -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: scout.example.com' "http://$NODE_IP:$NODE_PORT/"
```

The first command prints `True`. The second prints `False`, because `outpost` has no label `access=gateway`. The request returns the reply of `scout`.

## Why this is the answer

The `allowedRoutes` field on the listener is the control of the Gateway owner. With `from: Selector`, the owner of the namespace labels decides which teams may attach, and no application team edits the Gateway. `from: All` would also accept the route in `outpost`.
