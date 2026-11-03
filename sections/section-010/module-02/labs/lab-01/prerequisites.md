# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory.
- `kubectl`, `helm`, `curl` and `openssl` on your machine. The start script downloads the Cilium chart and the Gateway API CRD manifest, so it needs internet access. It uses `openssl` to make a self-signed certificate.
- You know what an Ingress is and how a TLS Secret is used.

The lab starts a kind cluster with one worker node, Cilium with the Ingress controller in dedicated mode, the Starfleet workloads in `starfleet` and `outpost`, and the TLS Secret `scout-tls`.
