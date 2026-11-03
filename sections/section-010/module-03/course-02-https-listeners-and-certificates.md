---
draft: true
---
# HTTPS Listeners And Certificates

A listener with the protocol `HTTPS` ends the TLS connection itself. It needs a certificate and a private key, and it takes them from a Kubernetes Secret. This part serves HTTPS from a Gateway, tests it, and shows why a Secret in another namespace needs explicit permission.

## Terminate TLS on a listener

**TLS termination** means the Gateway decrypts the request and sends it to the backend over plain HTTP. Make a self-signed certificate for the host `scout.example.com` and store it as a TLS Secret. The certificate is for tests only: clients do not trust it.

<!-- astrona:playground:renew -->

```sh
openssl req -x509 -nodes -newkey rsa:2048 -days 30 -keyout tls.key -out tls.crt -subj "/CN=scout.example.com" -addext "subjectAltName=DNS:scout.example.com"
kubectl -n starfleet create secret tls scout-tls --cert=tls.crt --key=tls.key
```

Save this as `gateway-secure.yaml`. It adds an HTTPS listener:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: secure
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

The field `tls.mode` is `Terminate` and `certificateRefs` names the Secret. A reference with no `namespace` means the namespace of the Gateway. Apply the Gateway and a route for it. Save this as `httproute-secure.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: secure-scout
  namespace: starfleet
spec:
  parentRefs:
    - name: secure
  hostnames:
    - scout.example.com
  rules:
    - backendRefs:
        - name: scout
          port: 80
```

```sh
kubectl apply -f gateway-secure.yaml
kubectl apply -f httproute-secure.yaml
```

## Send an HTTPS request

Read the node address and the node port of the Service port 443, then send a request. The option `--resolve` makes `curl` send the host name in the handshake while it connects to the node address:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HTTPS_PORT=$(kubectl -n starfleet get service cilium-gateway-secure -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -sk -m 8 --resolve "scout.example.com:$HTTPS_PORT:$NODE_IP" "https://scout.example.com:$HTTPS_PORT/"
```

The reply is the podinfo JSON document. The `-k` flag skips certificate checking because the certificate is self-signed. The proxy picks the certificate from the Server Name Indication (SNI) field, the host name that the client sends before the encryption starts.

## A Secret in another namespace

The platform team often keeps certificates in one namespace and runs Gateways in another. A Gateway may not read a Secret in another namespace by default, because anyone who could create a Gateway could then read any Secret. The Secret owner must allow it with a **ReferenceGrant**, a resource that lives in the namespace of the Secret and names who may refer to it. Save this as `referencegrant-certs.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-starfleet-gateways
  namespace: outpost
spec:
  from:
    - group: gateway.networking.k8s.io
      kind: Gateway
      namespace: starfleet
  to:
    - group: ""
      kind: Secret
```

The grant allows Gateways in `starfleet` to refer to Secrets in `outpost`. Without it, a `certificateRefs` entry with `namespace: outpost` sets `ResolvedRefs` to `False` with the reason `RefNotPermitted`. The grant can also name one Secret with `name` under `to`, which is the safer form. Apply it only if you plan to test a cross-namespace reference:

```sh
kubectl apply -f referencegrant-certs.yaml
```

## Several certificates on one listener

`certificateRefs` is a list, and the Gateway API allows several entries so that a listener can offer certificates of different key types. Keep one certificate per listener and use one listener per host name when hosts need different certificates.

## Common pitfalls

> [!WARNING]
> A Secret must have the type `kubernetes.io/tls`. A reference to a Secret in another namespace fails without a `ReferenceGrant` in the namespace of the Secret. The grant must name the namespace of the Gateway, not the namespace of the route. `curl` to a bare IP address sends no SNI, so use `--resolve` or a real name. A certificate whose names do not match the listener `hostname` works only for clients that skip verification.
