---
draft: true
---
# Observing Service Traffic With Hubble

A policy works only if you can show what it did. Hubble is the Cilium component that records the flows between pods, with the source, the destination and the verdict of each one. This part reads flows with the `hubble` command, finds the flows that a policy denied, and reads the HTTP details that Layer 7 rules add.

## What Hubble records

A **flow** is one observed network event between two endpoints, for example a TCP connection or an HTTP request. Each flow has a source, a destination, a verdict and metadata. The **verdict** says what Cilium did: `FORWARDED`, `DROPPED` or `ERROR`. The Cilium agent on each node records the flows of its own pods in a memory buffer. **Hubble Relay** is a pod that collects the flows of all nodes, so one command can show the whole cluster. The playground has Hubble and Hubble Relay enabled.

Hubble sees Layer 3 and Layer 4 flows from eBPF without any extra setting. It sees HTTP details only for traffic that Envoy handles, which means traffic that a Layer 7 rule selected.

## Read flows with the agent

The Cilium agent pod includes the `hubble` command, which reads the flows of its own node. Create some traffic first:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://scout.starfleet.svc/
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/get
```

Then list recent flows in the namespace `starfleet`:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --last 20
```

Each line shows a time, a source, an arrow, a destination, the type of event, the verdict and the protocol details. The lines for these two requests show `TCP` flows from the `shuttle` pod to the `scout` and `probe` pods with the verdict `FORWARDED`. The agent of a node holds only the flows of its pods, so run the command with `ds/cilium` as shown and read one node, or use Hubble Relay and a `hubble` client on your machine for the whole cluster.

## Filter by verdict and by pod

The `hubble observe` command has filters. The most useful filters are `--namespace`, `--pod`, `--verdict` and `--protocol`. Apply a policy first, so that one request is denied. Save this as `policy-probe-get.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-get
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
              - method: GET
                path: "/get"
```

Apply it, send one allowed request, one request that Envoy denies, and one request from `drifter`:

```sh
kubectl apply -f policy-probe-get.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/get
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/uuid
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/get
```

Now filter the flows:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --verdict DROPPED --last 20
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --protocol http --last 20
```

The first command lists the packets that the kernel dropped, which includes the attempt from `drifter` (the node that runs the `probe` pod records it). The second command lists the HTTP requests that Envoy saw, with the method, the URL and the response code of each one. The request to `/uuid` appears there, which shows the proxy handled it. Run the commands on each node's agent if a flow is missing, because a flow is recorded on the node of the destination or source endpoint it belongs to.

## Use flows to prove a policy

A flow gives the proof that a text description of a policy cannot give. To prove that `drifter` cannot reach `probe`, find a `DROPPED` flow with `drifter` as source and `probe` as destination. To prove that Envoy denies `/uuid`, find the HTTP flow for `/uuid` and read its response code. Check the policy verdicts in both directions, because a flow can leave the source and still be dropped at the destination.

The metrics are another form of the same data. Hubble can export counters such as the number of flows by verdict and the number of HTTP requests by status code. Prometheus can scrape these counters, and a dashboard or an alert on the rate of `DROPPED` flows shows a policy mistake after a release without anyone running `curl`.

## Clean up

Delete the policy so the playground returns to the open state:

```sh
kubectl -n starfleet delete ciliumnetworkpolicy probe-get
```

## Common pitfalls

> [!WARNING]
> Hubble shows HTTP details only for traffic that a Layer 7 rule sent through Envoy. Flows are kept in a ring buffer in memory, so old flows disappear, and a quiet cluster still needs a fresh request before you look. Read the flows on the node that runs the pod you test, or use Hubble Relay for the whole cluster. A `DROPPED` verdict and an HTTP `403` are different events, and they appear in different filters.
