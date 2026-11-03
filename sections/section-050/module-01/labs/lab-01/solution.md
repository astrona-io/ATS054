# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-01/labs/lab-01
```

## Step 1: Read the current state

```sh
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[*].name}{"\n"}'
kubectl -n starfleet get ciliumnetworkpolicy probe-l7
```

The Deployment lists two containers. The container `legacy-proxy` is the second.

## Step 2: Remove the leftover container

Remove the second container from the pod template with a JSON patch:

```sh
kubectl -n starfleet patch deployment probe --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/1"}]'
```

Check the position first. The index `1` is the second container. If the order differs on your cluster, use the index of `legacy-proxy`. Then wait for the rollout and submit:

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-01/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
kubectl -n starfleet get pods -l app=probe -o custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' -X POST http://probe.starfleet.svc/post
```

The pod lists one container. The first request returns `200` and the second returns `403`.

## Why this is the answer

The Layer 7 rule is enforced by the Envoy proxy of Cilium on the node, so the application pod needs no proxy container. The leftover container only used memory and it blocked nothing. A change to the pod template makes the Deployment create a new pod and remove the old one, and the policy follows the new pod because it selects pods by label.
