---
draft: true
---
# Mutual Authentication In Policies

A label-based rule says which workloads may talk. It does not prove that the caller really has that identity. Mutual authentication adds that proof, with a certificate on each side. This part shows the field in a policy and what the feature needs.

## The idea

Mutual authentication (mTLS) means both ends show a certificate that proves who they are, and both check the other. In Cilium, the identity comes from SPIFFE and the certificates are issued by a SPIRE server. The workload does not change: the agents on the two nodes do the handshake, and Cilium then allows the traffic in the policy.

## The policy field

The field is `authentication.mode` inside an allow rule. With the value `required`, a connection is allowed only after the two identities have been authenticated:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-mutual
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      authentication:
        mode: "required"
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
```

The rule is the same as in the first part, with one added field.

## What it needs

The feature needs SPIRE and a Helm setting. In the Helm chart, `authentication.mutual.spire.enabled=true` turns on the integration, and `authentication.mutual.spire.install.enabled=true` installs a SPIRE server and agents for you. The feature is documented as beta, so check the documentation of your Cilium version for its status and limits before you rely on it. This playground does not install SPIRE, so you can apply the policy only to read how it is accepted, and traffic that needs authentication will not pass.

## What it does not do

Mutual authentication proves identity at the start of a connection. It does not hide the traffic: for that, use transparent encryption with WireGuard or IPsec. The two features answer different questions and work together.

## Common pitfalls

> [!WARNING]
> Without SPIRE running, a rule with `mode: required` drops the traffic, because the authentication cannot succeed. Roll such a rule out one workload at a time. Mutual authentication is not encryption.
