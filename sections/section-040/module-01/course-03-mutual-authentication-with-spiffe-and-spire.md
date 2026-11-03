---
draft: true
---
# Mutual Authentication With SPIFFE And SPIRE

Encryption hides the traffic from the network, but it does not say who sent it. A pod that can reach a Service can send encrypted requests like any other pod. Authentication answers a different question: does the workload at the other end hold the identity that the policy names? This part explains how Cilium proves identity with SPIFFE and SPIRE, how a policy asks for it, and why encryption and authentication stay separate.

## Encryption, authentication and authorization

Three words are often mixed. **Encryption** makes the content unreadable on the network. **Authentication** proves who a party is. **Authorization** decides what an authenticated party may do. Transparent encryption with WireGuard or IPsec gives the first. Mutual authentication gives the second. A `CiliumNetworkPolicy` gives the third.

**Mutual authentication** means that both sides prove their identity, and not only the server. In mutual TLS (mTLS) each side shows a certificate that a trusted authority signed, and each side checks the other certificate. A workload without a valid certificate cannot complete the handshake, so a stolen pod IP address is not enough.

## SPIFFE and SPIRE

**SPIFFE** (Secure Production Identity Framework For Everyone) is a specification. It defines a workload identity, the SPIFFE ID, which is a URI such as `spiffe://cluster.local/ns/starfleet/sa/scout`. It also defines the SVID (SPIFFE Verifiable Identity Document), a short-lived X.509 certificate that carries the SPIFFE ID.

**SPIRE** is the implementation. A **SPIRE server** is the certificate authority that issues SVIDs, and a **SPIRE agent** runs on each node and hands SVIDs to the workloads on that node. The server decides which workload may receive which identity from registration entries. Cilium has been validated only with SPIRE, and other SPIFFE implementations are not supported.

## How Cilium uses it

Cilium does not put a sidecar or a library in the pod. The Cilium agent on the node talks to the SPIRE agent, and it asks for the identity of the pods on its node. The handshake between two nodes then runs between the Cilium agents, and each agent proves the identity of its pod. When the handshake succeeds, Cilium records the authentication in an eBPF map, and allowed traffic flows.

The first connection between two identities waits for the handshake. The following connections check the map and need no new handshake. A connection from a pod that cannot prove its identity is dropped.

## Install it and ask for it in a policy

The Helm values are `authentication.enabled=true`, `authentication.mutual.spire.enabled=true` and `authentication.mutual.spire.install.enabled=true`. The last value tells the chart to install SPIRE itself. For a lab cluster without persistent volumes, add `authentication.mutual.spire.install.server.dataStorage.enabled=false`, and accept that the data is lost when the SPIRE server pod restarts. The playground was installed with these values.

Find the SPIRE pods. The chart installs them in the namespace `cilium-spire`:

<!-- astrona:playground:renew -->

```sh
kubectl -n cilium-spire get pods
```

You see the SPIRE server and one SPIRE agent for each node. The policy field that asks for authentication is `authentication.mode` with the value `required`, written next to the rule it applies to. Save this as `policy-probe-auth.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-auth
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
      authentication:
        mode: "required"
```

Apply it:

```sh
kubectl apply -f policy-probe-auth.yaml
```

Then check the result:

```sh
kubectl -n starfleet get ciliumnetworkpolicy probe-auth
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/get
```

The request from `shuttle` is allowed only after the two nodes authenticate their pods. Remove the policy when you are done:

```sh
kubectl -n starfleet delete ciliumnetworkpolicy probe-auth
```

## Limits and status

Mutual authentication in Cilium is a beta feature. It has these limits. It works only inside one Cilium-managed cluster, and clusters joined by Cluster Mesh are not compatible, because there is no single trust domain across clusters. It is not compatible with an external mTLS solution. The documentation lists the WireGuard integration, a handshake for every connection and a security review as work that is not finished.

For an exam, remember what the feature adds and what it does not. It adds proof of identity in the handshake between nodes. It does not encrypt the application traffic by itself, so you still enable WireGuard or IPsec for confidentiality.

## What you know now

Mutual authentication proves workload identity with SPIFFE IDs and SVIDs that SPIRE issues, and a policy asks for it with `authentication.mode: required`. Encryption, authentication and authorization are three separate controls, and a complete design uses all three. The question that remains is how much of this each service needs.

## Common pitfalls

> [!WARNING]
> - Authentication does not encrypt. Enable WireGuard or IPsec when the traffic must be confidential.
> - The feature is beta. Do not use it as the only protection for a production service.
> - Cluster Mesh and external mTLS products are not supported with it.
> - Without persistent storage, the SPIRE server loses its data when its pod restarts.
