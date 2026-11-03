# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: Find the TLS Secret that exists

Read the `tls` entry of the Ingress and list the Secrets:

```sh
kubectl -n starfleet get ingress scout -o jsonpath='{.spec.tls}{"\n"}'
kubectl -n starfleet get secret
```

The Ingress names the Secret `scout-cert`. The Secret that exists is `scout-tls`, of type `kubernetes.io/tls`. Cilium cannot load a certificate that does not exist, so the HTTPS listener has no certificate for the host.

## Step 2: Name the right Secret

Save this as `ingress-scout.yaml`. It changes only the `secretName`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scout
  namespace: starfleet
spec:
  ingressClassName: cilium
  tls:
    - hosts:
        - scout.example.com
      secretName: scout-tls
  rules:
    - host: scout.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scout
                port:
                  number: 80
```

Apply it:

```sh
kubectl apply -f ingress-scout.yaml
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-02/labs/lab-01 --keep
```

## Step 3: Test by hand

Read the node address and the two node ports, then send an HTTPS request and an HTTP request:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HTTPS_PORT=$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
HTTP_PORT=$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -sk -m 8 --resolve "scout.example.com:$HTTPS_PORT:$NODE_IP" "https://scout.example.com:$HTTPS_PORT/"
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 8 -o /dev/null -w '%{http_code}\n' -H 'Host: scout.example.com' "http://$NODE_IP:$HTTP_PORT/"
```

The first request returns the podinfo reply. The `-k` flag skips the check of the certificate, because the certificate is self-signed. The second request prints a redirect status.

## Why this is the answer

The operator builds one Envoy filter chain per TLS host. It needs the Secret to build it. A wrong Secret name leaves the host without a certificate. When the Secret name is right, a host with a `tls` entry also gets the redirect from HTTP to HTTPS.
