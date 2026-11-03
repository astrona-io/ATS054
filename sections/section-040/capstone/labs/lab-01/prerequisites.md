# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory. The host kernel must support WireGuard for the encryption checks.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart, so it needs internet access.
- You know `helm upgrade` and what `--reuse-values` does.

The lab starts a kind cluster with one worker node, Cilium with WireGuard encryption, and the Starfleet workloads in `starfleet` and `outpost`.
