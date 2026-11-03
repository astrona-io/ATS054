# Question

Solve this question on: `terminal`

The `probe` pod in `starfleet` runs an HTTP test service on port 8080 and is open to every pod in the cluster. The security team wants it restricted at Layer 7.

Create one `CiliumNetworkPolicy` in `starfleet` that selects the pods labelled `app=probe` and meets all of these:

1. The pods labelled `app=shuttle` in `starfleet` can send `GET /get` and nothing else. `GET /uuid` and `POST /post` must be answered with HTTP `403`.
2. No other client can reach `probe`. The `drifter` pod in `outpost` must get no reply.
3. `scout` stays open. Do not create a policy for it. `drifter` must still get HTTP `200` from `http://scout.starfleet.svc/`.

The Service `probe` exposes port 80 and the pod listens on port 8080. You can send test requests with `kubectl exec` from the `shuttle` pod in `starfleet` and the `drifter` pod in `outpost`, which both have `curl`. `kubectl` already points at the cluster.
