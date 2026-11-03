---
draft: true
---
# Summary

You learned to prove that WireGuard runs and to find a fault when it does not.

## Key points

- The status line of each agent shows the mode, the device, the port and the peers.
- Counters of `cilium_wg0` prove that traffic is encrypted.
- Node encryption covers traffic that starts at a node; strict mode drops traffic that should be encrypted but is not.
- Allow UDP 51871 both ways, and account for 60 bytes of overhead in the MTU.
- Troubleshoot in order: setting, kernel, keys, peers, counters, MTU.

## What to practise

Read the status line, the peers and the counters in the playground, then change `encrypt-node` and read them again.

<!-- astrona:playground:destroy -->
