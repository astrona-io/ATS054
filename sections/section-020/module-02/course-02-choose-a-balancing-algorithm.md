---
draft: true
---
# Choose A Balancing Algorithm

Envoy can choose a backend in more than one way. The annotation `service.cilium.io/lb-l7-algorithm` selects the way. This part compares the three values and says when each fits.

## The three algorithms

- `round_robin` sends requests to the backends in turn. It is the default and fits backends that are equal and requests that cost about the same.
- `least_request` sends the next request to the backend with the fewest requests in flight. It fits requests with very different cost, because a slow backend gets fewer new requests.
- `random` picks a backend at random. It needs no state, and with many requests it comes close to an even split.

## Set the algorithm

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet annotate service probe-lb service.cilium.io/lb-l7=enabled service.cilium.io/lb-l7-algorithm=least_request --overwrite
kubectl -n starfleet get service probe-lb -o jsonpath='{.metadata.annotations}'
```

The output shows both annotations. Cilium updates the Envoy configuration in place, with no change to the pods or the clients.

## See the effect

Make one backend slow and watch the choice change. The go-httpbin path `/delay/2` answers after two seconds. Start a few slow requests in the background and send fast ones next to them:

```sh
for i in 1 2 3; do kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null http://probe-lb.starfleet.svc/delay/2 & done
for i in $(seq 1 12); do kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 http://probe-lb.starfleet.svc/hostname; echo; done | sort | uniq -c
wait
```

With `least_request`, the pods that hold slow requests get fewer of the fast ones. Switch the annotation to `round_robin` and repeat the test, and the fast requests spread evenly again, including to the busy pods. The numbers differ from run to run, so look at the trend and not at exact counts.

## Choose on facts

Use `round_robin` when requests are alike. Use `least_request` when some requests take much longer than others, for example reports and searches next to simple reads. Use `random` when you want the simplest policy and have many requests. Measure before you change the default.

## Common pitfalls

> [!WARNING]
> An unknown algorithm value is not what you want, so use only the three names above, in lower case with an underscore. The algorithm balances between the pods of one Service; it does not do sticky sessions. A pod that is not ready receives no requests whatever the algorithm is.
