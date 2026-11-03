---
draft: true
---
# URL Rewrite And Request Mirroring

Public URLs and backend URLs do not always match. A service may live under `/` inside the cluster while users reach it under `/probe`. A new version may need real traffic before anyone depends on it. This part rewrites the path or host that the backend sees and copies requests to a second backend.

## Rewrite the path prefix

The `URLRewrite` filter changes the request before it reaches the backend. The client never sees the change. With `path.type: ReplacePrefixMatch`, the part of the path that matched the rule prefix is replaced by `replacePrefixMatch`. Save this as `httproute-rewrite.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: rewrite
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
  hostnames:
    - rewrite.example.com
  rules:
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

Apply it and request `/probe/get`:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f httproute-rewrite.yaml
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -H 'Host: rewrite.example.com' "http://$NODE_IP:$NODE_PORT/probe/get"
```

go-httpbin has no path `/probe/get`, but it has `/get`. The reply is the JSON of `/get`, which shows that the backend received `/get`. The prefix `/probe` was replaced by `/`.

## Replace the whole path

The other type is `ReplaceFullPath`. It sends every matching request to one fixed path, whatever the original path was. Use it for a route that must always land on a known endpoint. `ReplacePrefixMatch` keeps the rest of the path, and `ReplaceFullPath` does not.

## Rewrite the host name

The same filter can set the `hostname` that the backend sees in the `Host` header. Add `hostname: probe.internal` under `urlRewrite`, and the backend receives that host and not `rewrite.example.com`. Use this when the backend serves several virtual hosts and only one name is valid.

## Mirror requests

The `RequestMirror` filter sends a copy of each matching request to a second backend. The client gets the answer from the main backend only, and the answer of the mirror is dropped. This is how you test a new version with real requests without risk. The mirror sees the request, but its failures do not reach the client. Add this to a rule:

```yaml
      filters:
        - type: RequestMirror
          requestMirror:
            backendRef:
              name: probe
              port: 80
```

The rule in the example sends the real answer from `scout` and a copy to `probe`. You can prove the copy arrived by reading the logs of the mirror backend:

```sh
kubectl -n starfleet logs deploy/probe --tail=5
```

A mirror only suits requests that are safe to repeat. A `POST` that creates an order would create it twice, once in each backend, so mirror reads, or mirror to a backend that is a harmless test copy.

## Common pitfalls

> [!WARNING]
> `ReplacePrefixMatch` works only with a `PathPrefix` match, so a rule with an `Exact` match cannot use it. The prefix is whole path elements: `/probe` matches `/probe/get` and not `/probes`. The rewritten path is what the backend sees, but the redirect `Location` and the client URL do not change. A mirror does not slow down the client reply, but it does add load to the mirror backend.
