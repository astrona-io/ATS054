# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart, so it needs internet access.
- You know what a pod template is and how `kubectl patch` or `kubectl edit` changes a Deployment.

The lab starts a kind cluster with one worker node, Cilium with the Envoy DaemonSet, and the Starfleet workloads in `starfleet` and `outpost`.
