# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Read the listener status

The status of the listener names the problem:

```sh
kubectl -n starfleet get gateway fleet -o jsonpath='{range .status.listeners[*].conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
kubectl -n starfleet get secret
```

The `ResolvedRefs` condition is `False`, because the listener names the Secret `scout-cert` and that Secret does not exist. The Secret that exists is `scout-tls`.

## Step 2: Name the right Secret

Save this as `gateway-fleet.yaml`. It changes only the name in `certificateRefs`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: fleet
  namespace: starfleet
spec:
  gatewayClassName: cilium
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      hostname: scout.example.com
      tls:
        mode: Terminate
        certificateRefs:
          - name: scout-tls
      allowedRoutes:
        namespaces:
          from: Same
```

Apply it:

```sh
kubectl apply -f gateway-fleet.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-03/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HTTPS_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -sk -m 8 --resolve "scout.example.com:$HTTPS_PORT:$NODE_IP" "https://scout.example.com:$HTTPS_PORT/"
```

The reply is the podinfo JSON document.

## Why this is the answer

A listener with an unresolved certificate cannot serve TLS, and the route that attaches to it cannot work. The route itself is correct, so only the listener needs a change.
