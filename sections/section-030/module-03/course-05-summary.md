---
draft: true
---
# Summary

You read what a cluster has of the Gateway API and where an implementation may differ.

## Key points

- The standard channel is stable; the experimental channel adds kinds that can change.
- CRD annotations show the channel and the bundle version.
- Core features are portable, Extended features depend on the controller, and implementation-specific ones are tied to it.
- Conformance reports show what a controller version passed.
- `ExtensionRef`, `parametersRef` and policies are the extension points.
- Install CRDs before Cilium, back up objects, and read status after an upgrade.

## What to practise

Read the channel, version and class status of a cluster, then list the policy kinds it offers.

<!-- astrona:playground:destroy -->
