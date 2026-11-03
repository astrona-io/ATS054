---
draft: true
---
# Layer 7 Visibility And Service Maps

Layer 3 and Layer 4 flows show who talked to whom and whether it was allowed. They do not show the HTTP method, the URL or the status code. This part explains why, how to get those details, and how the Hubble UI uses the same flows for a service map.

## Why HTTP needs a rule

Cilium sees packets in the kernel with eBPF. It does not parse HTTP there. To read HTTP it sends the traffic of a port through the Envoy proxy on the node. Cilium does that only when a policy has a Layer 7 rule for that port, so the visibility comes with the rule.

## Make HTTP visible

Write a policy with an `http` rule. An empty rule `- {}` allows every request and still sends the traffic through Envoy. Save this as `probe-visible.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-visible
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
          rules:
            http:
              - {}
```

<!-- astrona:playground:renew -->

```sh
kubectl apply -f probe-visible.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/get
hubble observe --namespace starfleet --protocol http --last 5
```

The flows now show the method `GET`, the URL path and the response code `200`, and the time the server took. For the layer 3 and 4 flows alone you would not get them.

## The service map

The Hubble UI draws the flows as a graph of services with arrows, and marks dropped edges. Start it with `cilium hubble ui` if the UI is installed. It is a view of the same data: the arrows are flows, and the colours follow the verdicts. Use it to see the shape of a system you do not know, and use the CLI when you need an exact line.

## What the cost is

Sending traffic through Envoy adds a hop and some CPU. Turn Layer 7 visibility on where you need HTTP details, and do not add `http` rules to every port of every pod only to see more.

## Common pitfalls

> [!WARNING]
> Without a Layer 7 rule you see no HTTP fields, even if the application speaks HTTP. A rule with an `http` section also enforces: once you list rules, requests that match none are denied with 403. Only the empty rule `- {}` allows all.
