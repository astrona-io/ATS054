# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory.
- `kubectl`, `helm` and `curl` on your machine. The start script downloads the Cilium chart and the Gateway API CRD manifest, so it needs internet access.
- You know how a `Gateway` and an `HTTPRoute` are written what `allowedRoutes` does and what a `ReferenceGrant` is for.

The lab starts a kind cluster with one worker node, Cilium with the Gateway API controller, and the Starfleet workloads in `starfleet` and `outpost`.
