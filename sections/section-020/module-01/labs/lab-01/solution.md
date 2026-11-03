# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: Check the starting state

No policy exists, so everything is open. Confirm it:

```sh
kubectl -n starfleet get ciliumnetworkpolicy
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/uuid
```

The list is empty and the request returns `200`.

## Step 2: Write the policy

Policy applies to the pod port, so the rule uses 8080, not the Service port 80. Save this as `policy-probe-get.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-get
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
kubectl apply -f policy-probe-get.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-01/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/uuid
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The first request returns `200`. The second returns `403`, which Envoy answers. The third prints `000` after five seconds, because the kernel drops the connection from `drifter`. The fourth returns `200`, because `scout` has no policy.

## Why this is the answer

`fromEndpoints` with the label `app=shuttle` limits who may connect, and the kernel drops everyone else. The `http` rule limits what an allowed client may send, and Envoy denies the rest. A policy on `probe` does not affect `scout`.
