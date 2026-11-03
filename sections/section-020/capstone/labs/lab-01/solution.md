# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Read the policies and test the current behaviour

```sh
kubectl -n starfleet get ciliumnetworkpolicy
kubectl -n starfleet get ciliumnetworkpolicy scout-access probe-access -o yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

The `scout-access` policy allows only `POST` and only the `shuttle` pods, so a `GET` from `shuttle` is answered with `403`. The `probe-access` policy names port 80. Policy applies to the pod port, which is 8080, so the request is dropped and `curl` prints `000` after five seconds.

## Step 2: Fix scout-access

Add the `drifter` pod as a second source and change the method to `GET`. A source in another namespace needs the namespace label. Save this as `policy-scout-access.yaml`:

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
        - matchLabels:
            app: drifter
            k8s:io.kubernetes.pod.namespace: outpost
      toPorts:
        - ports:
            - port: "9898"
              protocol: TCP
          rules:
            http:
              - method: GET
```

Apply it:

```sh
kubectl apply -f policy-scout-access.yaml
```

## Step 3: Fix probe-access

Change the port from 80 to 8080. Save this as `policy-probe-access.yaml`:

```yaml
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
kubectl apply -f policy-probe-access.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/capstone/labs/lab-01 --keep
```

## Step 4: Test by hand

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -X POST http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/uuid
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

The expected results are `200`, `200`, `403`, `200`, `403` and `000`. The kernel drops the connection from `drifter` to `probe`, and Envoy answers the `403` responses.
