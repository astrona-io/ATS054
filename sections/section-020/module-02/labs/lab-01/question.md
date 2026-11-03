# Question

Solve this question on: `terminal`

The Service `probe-lb` in the namespace `starfleet` sends traffic to the `probe` pods. Cilium is installed with the Envoy proxy and Layer 7 load balancing support. Turn on Layer 7 load balancing for this Service and choose the `least_request` algorithm. Change the annotations of the Service only: do not change its selector, its port or any other object.

When you are done, the Service must have both Cilium annotations, and a request from the pod `shuttle` in `starfleet` to `http://probe-lb.starfleet.svc/get` must return `200`. `kubectl` already points at the cluster.
