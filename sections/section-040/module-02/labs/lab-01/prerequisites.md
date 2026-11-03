# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory. WireGuard needs kernel support on the host that runs the container engine.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart, so it needs internet access.
- You can run a command in a Cilium agent with `kubectl exec`.

The lab starts a kind cluster with one worker node, Cilium with WireGuard and the Starfleet workloads in `starfleet` and `outpost`.
