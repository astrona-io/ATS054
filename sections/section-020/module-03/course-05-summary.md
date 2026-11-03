---
draft: true
---
# Summary

You restricted traffic by identity, by name and by entity, and read where mutual authentication fits.

## Key points

- A pod enters default deny in a direction when a policy selects it and has a section for that direction.
- Rules match labels, which Cilium turns into identities, and the pod port.
- `toFQDNs` needs a DNS rule that inspects lookups.
- Entities such as `world`, `kube-apiserver` and `ingress` name groups of endpoints.
- A deny rule wins over every allow rule, and policies are added together.
- `authentication.mode: required` needs SPIRE and proves identity, but does not encrypt.

## What to practise

Restrict the egress of one pod, then open DNS, one service and one name, and read each drop in Hubble.

<!-- astrona:playground:destroy -->
