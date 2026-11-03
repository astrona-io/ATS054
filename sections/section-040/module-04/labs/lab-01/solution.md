# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-04/labs/lab-01
```

## Step 1: Check that SPIRE runs

```sh
kubectl -n cilium-spire get pods
```

The server and one agent per node must be `Running`. Without them an authentication policy has nothing to use.

## Step 2: Write the policy

Save this as `scout-auth.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: scout-require-auth
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: scout
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      authentication:
        mode: required
      toPorts:
        - ports:
            - port: "9898"
              protocol: TCP
```

```sh
kubectl apply -f scout-auth.yaml
```

## Step 3: Test

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The first request prints `200`, maybe after one retry because the first packet is dropped while the agents authenticate. The second prints `000` because no rule accepts it.

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-04/labs/lab-01 --keep
```

## Why this is the answer

A rule with `authentication.mode: required` accepts traffic only after the two agents have verified the identities of the workloads with SPIRE. The rule has no `toPorts` rules at Layer 7, so Envoy is not involved. A source that no rule accepts gets its packets dropped.
