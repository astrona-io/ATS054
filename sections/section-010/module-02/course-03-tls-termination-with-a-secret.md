---
draft: true
---
# TLS Termination With A Secret

Traffic from a browser to an Ingress should be encrypted with Transport Layer Security (TLS), the protocol behind HTTPS. The proxy must hold a certificate and its private key for each host name. This part makes a certificate, stores it in a Kubernetes Secret, serves HTTPS for one host and explains what Cilium does with plain HTTP requests for that host.

## What termination means

**TLS termination** means the proxy ends the encrypted connection. Envoy decrypts the request, chooses the route from the host and path, and sends the request to the backend Service over plain HTTP. In Cilium, the Envoy proxy on the node does this work, and the Cilium operator gives it the certificate. The Ingress holds no key. It only names a Secret.

A TLS Secret is a Kubernetes Secret of type `kubernetes.io/tls`. It has two keys: `tls.crt` for the certificate chain and `tls.key` for the private key.

## Make a certificate and a Secret

Make a self-signed certificate for the host `scout.example.com`. This is a test certificate: a browser does not trust it, and production Ingress resources use a certificate from a certificate authority. Run this in your terminal:

<!-- astrona:playground:renew -->

```sh
openssl req -x509 -nodes -newkey rsa:2048 -days 30 -keyout tls.key -out tls.crt -subj "/CN=scout.example.com" -addext "subjectAltName=DNS:scout.example.com"
kubectl -n starfleet create secret tls scout-tls --cert=tls.crt --key=tls.key
```

The second command creates the Secret `scout-tls` in `starfleet`. The Secret must be in the same namespace as the Ingress that uses it.

## Add the tls entry

Save this as `ingress-scout-tls.yaml`. It adds a `tls` list to an Ingress for the host `scout.example.com`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scout-tls
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
kubectl apply -f ingress-scout-tls.yaml
```

The Cilium operator reads the Secret and copies it into the namespace `cilium-secrets`, because Envoy reads certificates from there. The Helm value `ingressController.secretsNamespace.name` sets that namespace. The copy means the Envoy proxy never needs permission to read Secrets in your application namespaces.

## Send an HTTPS request

The entry point Service now has a port named `https`. Read both node ports and send the request with `--resolve`, so that `curl` sends the host name in the TLS handshake while it connects to the node IP address:

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HTTPS_PORT=$(kubectl -n starfleet get service cilium-ingress-scout-tls -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
HTTP_PORT=$(kubectl -n starfleet get service cilium-ingress-scout-tls -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
kubectl -n starfleet exec deploy/shuttle -- curl -sk -m 8 --resolve "scout.example.com:$HTTPS_PORT:$NODE_IP" "https://scout.example.com:$HTTPS_PORT/"
```

The reply is the podinfo JSON document. The `-k` flag skips the check of the certificate, which is needed here only because the certificate is self-signed. Envoy picks the certificate with the Server Name Indication (SNI) field of the handshake, the host name that the client sends in clear text before the encryption starts. A client that connects by IP address sends no SNI and Envoy has no certificate to match, which is why the plain IP address does not work.

## The redirect from HTTP to HTTPS

Send a plain HTTP request for the same host and print the status code and the `Location` header:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 8 -o /dev/null -D - -H 'Host: scout.example.com' "http://$NODE_IP:$HTTP_PORT/"
```

By default Cilium redirects HTTP requests for a host that has a `tls` entry to HTTPS, and the Helm value `ingressController.enforceHttps` controls the default. The annotation `ingress.cilium.io/force-ssl-redirect` overrides it for one Ingress. Set it to `"false"` and the same request reaches the backend over HTTP.

## Default certificate

Two Helm values, `ingressController.defaultSecretNamespace` and `ingressController.defaultSecretName`, name a Secret that Cilium uses for an Ingress with a `tls` entry that has no `secretName`. Use it for a wildcard certificate that covers every host in the cluster. A `tls` entry that names a Secret always wins over the default.

## Common pitfalls

> [!WARNING]
> The Secret must be in the namespace of the Ingress and must have the type `kubernetes.io/tls`. A `secretName` with a typo leaves the host without a certificate. Read the Cilium operator log when HTTPS does not work. The hosts in `tls.hosts` must match the rule host and the names in the certificate. `curl` to an IP address sends no SNI, so use `--resolve` or a real DNS name.
