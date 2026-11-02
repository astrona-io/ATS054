---
draft: true
exam_objectives:
- Encrypting Traffic in Transit with Cilium
---
# Enable Cross Node WireGuard Encryption

Enable WireGuard and verify agent encryption state and cross-node requests.

The task and solution use a separate pinned kind cluster. Run `testing/smoke.sh` with its private kubeconfig to verify initial rejection and reference success. Static validation is not live evidence. Runtime verification remains pending.
