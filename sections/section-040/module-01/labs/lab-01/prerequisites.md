# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory. The host kernel must support WireGuard for the encryption checks.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart, so it needs internet access.
- You know what a ConfigMap is and how to restart a DaemonSet with `kubectl rollout restart`.

The lab starts a kind cluster with one worker node, Cilium without encryption, and the Starfleet workloads in `starfleet` and `outpost`.
