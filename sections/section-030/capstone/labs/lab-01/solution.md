# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Read the two failing conditions

```sh
kubectl -n outpost get httproute probe -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0].allowedRoutes}{"\n"}'
kubectl get namespace outpost --show-labels
```

`Accepted` is `False` because the namespace `outpost` does not carry the label `access=gateway`. `ResolvedRefs` is `False` because the route in `outpost` has no permission to use a Service in `starfleet`.

## Step 2: Label the namespace

```sh
kubectl label namespace outpost access=gateway
```

## Step 3: Add the grant in the namespace of the Service

Save this as `referencegrant-probe.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-outpost-routes
  namespace: starfleet
spec:
  from:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      namespace: outpost
  to:
    - group: ""
      kind: Service
      name: probe
```

Apply it:

```sh
kubectl apply -f referencegrant-probe.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/capstone/labs/lab-01 --keep
```

## Step 4: Test by hand

```sh
kubectl -n outpost get httproute probe -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status}{"\n"}{end}'
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n edge get service cilium-gateway-edge-gw -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -H 'Host: probe.example.com' "http://$NODE_IP:$NODE_PORT/uuid"
```

Both conditions are `True`, and the request returns `200`.

## Why this is the answer

Attachment and backend access are two separate agreements. The Gateway owner allows namespaces with a label. The Service owner allows references with a ReferenceGrant in the namespace of the Service. Listing only `HTTPRoute` from `outpost` and only the Service `probe` gives the smallest right.
