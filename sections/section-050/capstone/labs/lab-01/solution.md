# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/capstone/labs/lab-01
```

## Step 1: Read the current state

```sh
kubectl -n starfleet get deployments scout probe -o custom-columns=NAME:.metadata.name,CONTAINERS:.spec.template.spec.containers[*].name
kubectl -n starfleet get ciliumnetworkpolicy
```

Each Deployment lists two containers, and no policy exists.

## Step 2: Remove the leftover containers

The container `mesh-proxy` is the second container of both Deployments:

```sh
kubectl -n starfleet patch deployment scout --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/1"}]'
kubectl -n starfleet patch deployment probe --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/1"}]'
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/probe --timeout=180s
```

## Step 3: Save the two policies

Save this as `access.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: scout-access
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: scout
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      toPorts:
        - ports:
            - port: "9898"
              protocol: TCP
          rules:
            http:
              - method: GET
---
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-access
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
          rules:
            http:
              - method: GET
                path: "/get"
```

Apply it:

```sh
kubectl apply -f access.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/capstone/labs/lab-01 --keep
```

## Step 4: Test by hand

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -X POST http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/uuid
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The results are `200`, `403`, `403` and `000`.

## Why this is the answer

An HTTP rule in a CiliumNetworkPolicy sends the matching connections to the Envoy proxy on the node, and Envoy answers `403` to a request that no rule allows. A source that no `fromEndpoints` entry names is dropped in the kernel, so the client sees a timeout, which curl reports as `000`. The rules apply to the pod ports 9898 and 8080 because Cilium sees the traffic after the Service is translated to a pod address. The policy moves the access rules out of the pods, so the sidecars have nothing left to do.
