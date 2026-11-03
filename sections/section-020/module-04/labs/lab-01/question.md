# Question

Solve this question on: `terminal`

The team wants to see the HTTP requests from the pod `shuttle` to the pod `probe` in Hubble: method, path and status. Hubble shows these only for traffic that passes a Layer 7 rule. Write one `CiliumNetworkPolicy` in the namespace `starfleet` for the pods with the label `app: probe` that:

1. Accepts traffic only from the pods with the label `app: shuttle`, on the pod port 8080.
2. Allows the method `GET` for the path `/get` and for every path under `/status/`.
3. Allows nothing else, so that a request for `/uuid` gets `403`.

`kubectl` already points at the cluster.
