# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-04/labs/lab-01
```

## Step 1: Why a policy gives visibility

Hubble sees Layer 3 and Layer 4 flows without any setup. HTTP method, path and status appear only when the traffic goes through the Envoy proxy, and a Layer 7 rule in a policy sends it there.

## Step 2: Write the policy

Save this as `probe-http.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-http-visible
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
              - method: GET
                path: "/status/.*"
```

```sh
kubectl apply -f probe-http.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-04/labs/lab-01 --keep
```

## Step 3: Test by hand and look in Hubble

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/uuid
hubble observe --namespace starfleet --protocol http --last 10
```

The requests print `200` and `403`. In Hubble the flows show the method, the URL and the HTTP status, and the request for `/uuid` has the verdict `DROPPED`.

## Why this is the answer

The `http` rules make Cilium redirect the port to the Envoy proxy, which can enforce the method and path and report them to Hubble. A request that no rule allows gets `403` from Envoy.
