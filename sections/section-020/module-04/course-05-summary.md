---
draft: true
---
# Summary

You read flows and metrics to see what a Cilium cluster does with traffic.

## Key points

- Hubble records flows with source, destination, identity, type and verdict.
- `hubble observe` filters by namespace, pod, verdict and protocol.
- A `DROPPED` flow with `Policy denied` points at a policy.
- HTTP details appear only for traffic that passes a Layer 7 rule.
- The agent, operator, Envoy and Hubble publish metrics on ports 9962 to 9965.
- Choose Hubble metric groups by the question you want to answer.

## What to practise

Break a call with a policy, find the drop with a filter, fix it, and check for `FORWARDED`.

<!-- astrona:playground:destroy -->
