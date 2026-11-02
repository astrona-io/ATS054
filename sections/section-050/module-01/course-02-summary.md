---
draft: true
exam_objectives:
- Sidecar-based versus Sidecarless Architectures
---
# Summary

Sidecars place proxy processing alongside each workload, while sidecarless designs can share node-level processing and use datapath redirection. Both arrangements still need configured protocol and security behavior.

Resource cost, rollout ownership and failure scope change with placement. Shared processing is not proxy-free, and architecture alone does not establish complete encryption, authentication or authorization for every application path.
