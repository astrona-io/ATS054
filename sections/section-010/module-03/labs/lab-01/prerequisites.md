# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use, with about 4 GiB of free memory.
- `kubectl`, `helm`, `curl` and `openssl` on your machine. The start script downloads the Cilium chart and the Gateway API CRD manifest, so it needs internet access. It uses `openssl` to make a self-signed certificate.
- You know what a Gateway listener is and how an HTTPRoute attaches to it.

The lab starts a kind cluster with one worker node, Cilium with the Gateway API controller, the Starfleet workloads and the TLS Secret `scout-tls`.
