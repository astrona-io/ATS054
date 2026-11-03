# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart, so it needs internet access.

The lab starts a kind cluster with one worker node, Cilium with the `cilium-envoy` DaemonSet, the Starfleet workloads, and a legacy pod `relay` in `outpost` that has a second container named `proxy`.
