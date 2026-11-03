---
draft: true
---
# Summary

A sidecar mesh puts a proxy container in every pod. A mutating admission webhook adds it when the pod is created, `iptables` rules in the pod redirect all traffic to it, and a control plane configures it over xDS and issues its identity. This isolates failures per pod and gives full Layer 7 features, but it costs one proxy for each pod, needs a restart of each pod to upgrade the proxy, and brings startup-order and Job-completion problems.

Cilium is sidecarless. eBPF programs in the kernel handle identity-based Layer 3 and Layer 4 policy, load balancing and encryption. Connections that a Layer 7 rule governs are redirected with TPROXY to the Envoy proxy of the `cilium-envoy` DaemonSet on the same node. Application pods keep their own specification, start and stop normally, and are not restarted when a policy changes or when the proxy is upgraded. Sidecarless does not mean proxy-less. It means that the proxy runs on the node and not in the pod.

Ambient, the second node-level design, uses a ztunnel on each node for Layer 4 and an optional waypoint proxy for Layer 7.

Moving the proxy out of the pod makes the cost grow with nodes and not with pods, removes pod restarts from upgrades and takes the proxy out of the trust boundary of the application. In exchange, the proxy becomes shared. A failure or a bad upgrade affects all pods on a node that depend on it for Layer 7, a busy workload can use the capacity of the proxy, and the platform team must size and upgrade it with care.

- Count proxies: one per pod for a sidecar, one per node for a node-level design.
- Layer 3 and Layer 4 traffic in Cilium never reaches Envoy.
- A policy applies to the pod port, not to the Service port.
- A design label does not guarantee encryption or authentication.

<!-- astrona:playground:destroy -->
