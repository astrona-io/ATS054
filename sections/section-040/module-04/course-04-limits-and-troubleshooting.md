---
draft: true
---
# Limits And Troubleshooting

Mutual authentication gives a strong answer to one question and no answer to others. Know the edge before you promise anything.

## What it does

It proves, for each pair of workloads that a rule names, that both sides hold a valid identity from the trust domain before traffic flows.

## What it does not do

- **It does not encrypt traffic.** The handshake uses certificates, but the data of the connection is not protected by it. Use WireGuard or IPsec for encryption. In the playground WireGuard is on for that reason.
- **It does not authorize by itself.** The selectors in the rule decide who may talk. Authentication only adds a proof.
- **It does not replace application-level checks.** A pod that is allowed can still send bad requests to the service.
- **It depends on SPIRE.** If the server or the agents are down, new pairs cannot be authenticated, and traffic that needs it is dropped.

The feature is still developing in Cilium. Read the status of mutual authentication in the documentation of your version before you rely on it.

## Troubleshooting order

1. Are the SPIRE pods `Running` on every node? (`kubectl -n cilium-spire get pods`)
2. Does the policy have the field in the right rule, and does it select the right pods?
3. Does the SPIRE server have entries for the workloads?
4. Does the table of the agent get an entry after traffic?
5. Do drops with an authentication reason continue in Hubble?
6. Read the logs of the Cilium agent and the SPIRE agent for handshake errors.

<!-- astrona:playground:renew -->

```sh
kubectl -n cilium-spire logs statefulset/spire-server -c spire-server --tail=20
```

## Common pitfalls

> [!WARNING]
> Do not store SPIRE server data on an `emptyDir` in production. When the pod restarts, the server loses its keys and issues new ones, and every pair has to authenticate again. Plan persistent storage, backups and a rotation of the upstream authority.
