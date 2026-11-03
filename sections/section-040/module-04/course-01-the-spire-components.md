---
draft: true
---
# The SPIRE Components

SPIFFE is a standard for workload identity. SPIRE is a program that implements it. Cilium does not issue identities itself: it asks SPIRE.

## The parts

- A **SPIRE server** (a StatefulSet in `cilium-spire`) is the authority of a **trust domain**. It signs the identity documents.
- A **SPIRE agent** (a DaemonSet in the same namespace) runs on each node, proves the node to the server and hands out identities to the workloads on its node.
- The **Cilium agent** on each node talks to the local SPIRE agent to get an identity document for a workload and to check the document of the other side.
- The **Cilium operator** creates a **registration entry** in the SPIRE server for the identities that Cilium knows. An entry says which workload gets which identity.

## The identity

An identity is a **SPIFFE ID**, a URI. Its first part is the trust domain, `spiffe://spiffe.cilium` by default, and the rest names the workload. The document that proves it is an **SVID**, a short-lived X.509 certificate that the SPIRE server signs and renews before it expires.

## Look at it

<!-- astrona:playground:renew -->

```sh
kubectl -n cilium-spire get pods -o wide
kubectl -n cilium-spire get statefulset,daemonset
```

You see one server pod and one agent pod for each node, all `Running`. The playground sets the server's data storage off, so the server forgets everything when its pod restarts and the identities are issued again. That is fine for learning and wrong for production, where the data must persist.

## Common pitfalls

> [!WARNING]
> Do not mix up the SPIRE trust domain with a Kubernetes namespace or a DNS domain. It is a name for the authority, and a workload outside it cannot be verified. Production needs persistent storage for the server and a plan for its upstream certificate.
