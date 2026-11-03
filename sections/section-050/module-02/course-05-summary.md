---
draft: true
---
# Summary

You checked a sidecarless cluster and compared its cost, upgrades, failures and boundaries with a sidecar design.

## Key points

- `cilium` and `cilium-envoy` run once per node; application pods carry no proxy.
- Layer 3 and Layer 4 traffic stays in the kernel; Layer 7 rules go through the node proxy.
- The saving comes from the pod density, so measure it.
- Upgrades are owned by the platform team and go node by node.
- A node proxy failure affects the Layer 7 traffic of one node.
- The shared proxy trades per-pod isolation for no injection and lower cost.

## What to practise

Count pods and containers, scale an application and count the proxies again, and restart the proxy while traffic runs.

<!-- astrona:playground:destroy -->
