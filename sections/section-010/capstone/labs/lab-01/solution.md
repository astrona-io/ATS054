# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Give the Ingress a class

Cilium only owns Ingress resources that select its class. List what exists:

```sh
kubectl get ingressclass
kubectl -n starfleet get ingress scout -o yaml
kubectl -n starfleet get service
```

The Ingress has no `ingressClassName`, and no Service named `cilium-ingress-scout` exists. Set the class:

```sh
kubectl -n starfleet patch ingress scout --type merge -p '{"spec":{"ingressClassName":"cilium"}}'
```

Cilium now creates the Service `cilium-ingress-scout`. Test it:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: scout.example.com' "http://$NODE_IP:$NODE_PORT/"
```

## Step 2: Find why the route is not accepted

```sh
kubectl -n starfleet get httproute probe -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0].allowedRoutes}{"\n"}'
kubectl get namespace starfleet --show-labels
```

The `Accepted` condition is `False` with the reason `NotAllowedByListeners`. The listener has `from: Selector` with the label `access=gateway`, and the namespace `starfleet` does not have that label.

## Step 3: Label the namespace

The namespace label is the control that the platform team uses to allow a namespace. Add it:

```sh
kubectl label namespace starfleet access=gateway
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/capstone/labs/lab-01 --keep
```

## Step 4: Test the route

```sh
NODE_PORT=$(kubectl -n edge get service cilium-gateway-edge-gw -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -H 'Host: probe.example.com' "http://$NODE_IP:$NODE_PORT/uuid"
```

The reply is `200` from go-httpbin.
