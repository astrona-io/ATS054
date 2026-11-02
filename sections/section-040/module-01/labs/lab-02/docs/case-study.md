---
draft: true
exam_objectives:
- Encrypting Traffic in Transit with Cilium
---
# Starting Environment

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Enable WireGuard and verify agent encryption state and cross-node requests.
