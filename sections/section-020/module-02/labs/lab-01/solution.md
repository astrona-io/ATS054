# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Read the Service

```sh
kubectl -n starfleet get service probe-lb -o yaml
```

The Service has no annotations. Cilium does Layer 4 load balancing for it in the kernel. Two annotations ask for Layer 7 load balancing in the Cilium Envoy proxy.

## Step 2: Annotate the Service

```sh
kubectl -n starfleet annotate service probe-lb service.cilium.io/lb-l7=enabled service.cilium.io/lb-l7-algorithm=least_request --overwrite
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-02/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe-lb.starfleet.svc/get
```

The command prints `200`. Requests now pass through Envoy on the node, which picks the backend per request.

## Why this is the answer

The annotation `service.cilium.io/lb-l7` hands the Service to the Envoy proxy, and `service.cilium.io/lb-l7-algorithm` picks how Envoy chooses a backend. The three values are `round_robin`, `least_request` and `random`.
