# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 6 GiB of free memory. SPIRE adds a server and an agent per node.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart, so it needs internet access.
- You can write a `CiliumNetworkPolicy`.

The lab starts a kind cluster with one worker node, Cilium with mutual authentication (SPIRE in `cilium-spire`) and the Starfleet workloads in `starfleet` and `outpost`.
