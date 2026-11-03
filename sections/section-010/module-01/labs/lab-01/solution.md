# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Read why the route does not work

The status of the route tells you which field is wrong:

```sh
kubectl -n starfleet get httproute fleet -o jsonpath='{range .status.parents[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
kubectl -n starfleet get gateway
kubectl -n starfleet get service scout
```

The route names a parent Gateway `fleet-gw`, but the Gateway is named `fleet`. The route also sends traffic to port `8080`, but the Service `scout` exposes port `80`. Both fields are in the route, and the Gateway needs no change.

## Step 2: Fix the parent and the port

Save this as `httproute-fleet.yaml`. It fixes both fields and adds the header rule from the second task:

```yaml
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
        - headers:
            - name: x-fleet
              value: probe
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

Apply it:

```sh
kubectl apply -f httproute-fleet.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-01/labs/lab-01 --keep
```

## Step 3: Test by hand

Read the node address and node port, then send both kinds of request:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: fleet.example.com' "http://$NODE_IP:$NODE_PORT/"
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -H 'Host: fleet.example.com' -H 'x-fleet: probe' "http://$NODE_IP:$NODE_PORT/uuid"
```

The first request returns the podinfo reply. The second returns `200` from go-httpbin. A request to `/uuid` without the header returns `404` from podinfo.

## Why this is the answer

The `Accepted` condition was `False` because the parent name matched no Gateway. A wrong backend port makes `ResolvedRefs` or the request itself fail. The header rule comes first in the list because the Gateway API prefers the more specific match, and the path rule catches everything else.
