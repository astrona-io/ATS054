---
draft: true
exam_objectives:
- Encrypting Traffic in Transit with Cilium
---
# Summary

Transparent encryption protects supported traffic segments through the configured Cilium mechanism, such as IPsec or WireGuard. Its coverage depends on the deployed mode and path rather than the name of the feature alone.

Application TLS, authenticated workload identity and authorization remain separate decisions. Key lifecycle, peer reachability and packet overhead require review, with evidence for actual protected paths and documented exclusions.
