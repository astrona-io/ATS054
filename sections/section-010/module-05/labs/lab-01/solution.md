# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-05/labs/lab-01
```

## Step 1: Read the status

```sh
kubectl -n starfleet describe httproute fleet
```

The status of the parent shows `Accepted` with the status `False`. The reason is `NoMatchingParent`: the route asks for a listener named `websecure`, and the Gateway has only `web`. A route must name an existing listener in `sectionName`.

## Step 2: Fix the listener name and the host

Change `sectionName` to `web`. The route would still not be accepted after that, because its host `fleet.example.org` does not overlap with the listener host `*.example.com`. Change it to `fleet.example.com`.

## Step 3: Fix the backend port

After the route is accepted, `ResolvedRefs` is still `False` with the reason `BackendNotFound`, because the Service `scout` listens on port 80 and the route asks for 8080. Check with `kubectl -n starfleet get service scout`.

Save the repaired route as `httproute-fleet.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: fleet
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
      sectionName: web
  hostnames:
    - fleet.example.com
  rules:
    - backendRefs:
        - name: scout
          port: 80
```

```sh
kubectl apply -f httproute-fleet.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-05/labs/lab-01 --keep
```

## Why this is the answer

Each fault sits at a different level, and each one shows in a different condition. A listener name or host fault shows in `Accepted`. A backend fault shows in `ResolvedRefs`. Read the conditions in order and fix one level at a time.
