---
draft: true
---
# Summary

The Cilium operator turns each Ingress into an Envoy listener configuration and a Service. In dedicated mode every Ingress gets its own Service named after it. In shared mode all Ingress resources use one Service in the namespace where Cilium runs. A Helm value sets the mode for the whole cluster, and an annotation overrides it for one Ingress. The same two layers apply to the Service type: a Helm value for the shared Service and an annotation for a dedicated one.

Envoy picks the host first, then the path. `Exact` matches one path, `Prefix` matches whole path elements, and `ImplementationSpecific` is a regular expression in Cilium. The longest match wins and an `Exact` match beats a `Prefix` of the same value. The order of rules in the manifest does not matter. A catch-all rule returns a reply for every typo, so a test must check the body and not only the status code.

TLS termination needs a Secret of type `kubernetes.io/tls` in the namespace of the Ingress and a `tls` entry with the hosts and the Secret name. The operator copies the Secret to a namespace that Envoy can read. Envoy selects the certificate from the SNI field, so a client that connects by IP address needs `--resolve` or a real name. A host with a `tls` entry redirects plain HTTP to HTTPS by default.

Clients reach the entry point through a load balancer address, a node port or a host network port. `externalTrafficPolicy` decides whether a request can cross nodes and whether the client address is kept. A gRPC backend needs `appProtocol: kubernetes.io/h2c` on its Service port.

- Dedicated mode gives one Service per Ingress. Shared mode gives one Service for all.
- The annotation `ingress.cilium.io/loadbalancer-mode` sets the mode for one Ingress.
- The longest path wins, not the first one in the file.
- A TLS Secret in the wrong namespace or with a wrong name leaves the host without a certificate.
- `kubernetes.io/h2c` on the Service port is the gRPC setting.

<!-- astrona:playground:destroy -->
