---
draft: true
---
# Summary

You learned how Cilium runs IPsec and how to manage its keys.

## Key points

- The kernel holds states (with keys and SPIs) and policies; the agent builds them from one Secret.
- The key line has four fields: SPI, algorithm, a 40-character hex key and the ICV size.
- Rotate by writing a new key with the next SPI and checking every node.
- Allow ESP (IP protocol 50) between nodes.
- Choose IPsec when a rule requires it, and WireGuard otherwise.

## What to practise

Build a key line, check its length, and read the empty XFRM tables of a cluster that has no IPsec.

<!-- astrona:playground:destroy -->
