---
draft: true
---
# Plan A Cutover With A Rollback

The Gateway is built and accepted. The last step is to move real clients without an outage. The Ingress and the Gateway have different Services and addresses, so the switch happens in DNS or in a load balancer in front of the cluster. This part plans the switch so that you can undo it.

## Run both, then compare

Both entry points serve the same routes at the same time, so nothing is lost while you test. Send the same request to each, with the production host name in the `Host` header:

<!-- astrona:playground:renew -->

```sh
NODE_IP=$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
ING_PORT=$(kubectl -n starfleet get service cilium-ingress-fleet -o jsonpath='{.spec.ports[0].nodePort}')
GW_PORT=$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}')
for p in $ING_PORT $GW_PORT; do for path in / /probe; do kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w "$p $path %{http_code}\n" -H 'Host: fleet.example.com' "http://$NODE_IP:$p$path"; done; done
```

The four lines show the status codes of both entry points for both paths. They must match. Any difference is a bug in the migration.

## The cutover plan

1. **Lower the DNS TTL** a day before, so a rollback takes effect fast.
2. **Test** the Gateway with the `Host` header for every route, TLS included.
3. **Switch** the DNS name (or the load balancer target) to the Gateway address. Keep the Ingress running.
4. **Watch** error rates and Hubble drops for the length of one cache TTL and one business cycle.
5. **Roll back** by pointing the name at the Ingress address again if something is wrong. This is why the Ingress stays.
6. **Delete** the Ingress only after the Gateway has carried real traffic without problems.

## Clean up

When the Ingress is no longer needed:

```sh
kubectl -n starfleet delete ingress fleet
kubectl -n starfleet get gateway,httproute
```

The Gateway and the route keep working, because they never depended on the Ingress. Also remove the Ingress from the deployment tooling, so it is not applied again.

## Common pitfalls

> [!WARNING]
> Two entry points mean two sets of certificates and two addresses: check both before the switch. If a client has the old IP address cached or pinned, it keeps using the Ingress, so do not delete it too early. Do not run the cutover and a release in the same hour.
