---
draft: true
---
# Summary

You learned to choose a mesh architecture per workload and to migrate in small, checked steps.

## Key points

- Decide per workload from stated questions, and write the decision down.
- Build an inventory of injection labels, sidecar pods, Layer 7 policies and node proxy readiness.
- Map each feature by its guarantee, not by its name.
- Migrate one namespace at a time: policies first, stop injection, restart, check.
- Give every step a check and a rollback.
- Remove the old control plane and its webhooks last.

## What to practise

Run the inventory commands, label and unlabel a namespace, restart a workload and read its containers.

<!-- astrona:playground:destroy -->
