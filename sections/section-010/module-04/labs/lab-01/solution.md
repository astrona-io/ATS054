# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-04/labs/lab-01
```

## Step 1: Read the route

```sh
kubectl -n starfleet get httproute fleet -o yaml
```

The route has one rule with no `matches` and the backend `scout`. A rule without `matches` takes every request, so the two new rules need paths and must be more specific than that rule.

## Step 2: Add the redirect and the rewrite

Save this as `httproute-fleet.yaml`:

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
        - path:
            type: PathPrefix
            value: /old
      filters:
        - type: RequestRedirect
          requestRedirect:
            hostname: probe.example.com
            statusCode: 301
    - matches:
        - path:
            type: PathPrefix
            value: /probe
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
      backendRefs:
        - name: probe
          port: 80
    - backendRefs:
        - name: scout
          port: 80
```

Apply it:

```sh
kubectl apply -f httproute-fleet.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-04/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code} %{redirect_url}\n' -H 'Host: fleet.example.com' "http://$NODE_IP:$NODE_PORT/old/page"
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: fleet.example.com' "http://$NODE_IP:$NODE_PORT/probe/uuid"
```

The first request prints `301` and a URL with the host `probe.example.com`. The second returns a JSON document with a `uuid` field from go-httpbin.

## Why this is the answer

A filter changes the request or the response inside a rule, and a rule applies only to requests that match it. The rewrite replaces the matched prefix `/probe` with `/`, so the backend sees `/uuid`. The rule without `matches` stays last in the list as the default.
