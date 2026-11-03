# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: Understand the default

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

It prints `200`: with no policy every pod can reach every other pod. A pod becomes restricted in one direction when a policy selects it and has a section for that direction.

## Step 2: Write the policy

Save this as `shuttle-egress.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: shuttle
  egress:
    - toEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: kube-system
            k8s-app: kube-dns
      toPorts:
        - ports:
            - port: "53"
              protocol: ANY
          rules:
            dns:
              - matchPattern: "*"
    - toEndpoints:
        - matchLabels:
            app: scout
      toPorts:
        - ports:
            - port: "9898"
              protocol: TCP
```

```sh
kubectl apply -f shuttle-egress.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-03/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

The first prints `200`, the second prints `000` after the timeout, and the third prints `200`.

## Why this is the answer

The `endpointSelector` limits the policy to `shuttle`. An `egress` section turns on default deny for the egress of the selected pods, so only the two rules are allowed. The DNS rule is needed because the name lookup is also egress traffic. The port is the pod port 9898, because Cilium checks the policy after the Service address is translated to a backend.
