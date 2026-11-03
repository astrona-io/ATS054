# Question

Solve this question on: `terminal`

The platform team wrote two `CiliumNetworkPolicy` objects in `starfleet`, and both are wrong. Edit them in place. Do not delete them and do not add a policy that allows everything.

1. `scout-access` protects `scout`. The `shuttle` pods in `starfleet` and the `drifter` pod in `outpost` must be able to send `GET` requests to `scout`. Every other method, such as `POST`, must be answered with HTTP `403`.
2. `probe-access` protects `probe`. The `shuttle` pods can send `GET /get` and nothing else. `GET /uuid` must be answered with `403`. The `drifter` pod must get no reply.

The Service `scout` exposes port 80 and the pod listens on port 9898. The Service `probe` exposes port 80 and the pod listens on port 8080. You can send test requests with `kubectl exec` from the `shuttle` pod in `starfleet` and the `drifter` pod in `outpost`, which both have `curl`. `kubectl` already points at the cluster.
