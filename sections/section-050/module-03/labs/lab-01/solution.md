# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-03/labs/lab-01
```

## Step 1: Find the injected namespaces

```sh
kubectl get namespaces -l sidecar.example.io/inject=true
```

## Step 2: Count the sidecar pods

```sh
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CONTAINERS:.spec.containers[*].name | grep -E 'starfleet|outpost'
```

One pod, `relay` in `outpost`, has a second container named `proxy`.

## Step 3: Count the Layer 7 policies and check the node proxy

```sh
kubectl get cnp -A
kubectl -n starfleet get cnp probe-get-only -o yaml | grep -A3 rules
kubectl -n kube-system get daemonset cilium-envoy
```

One policy has an HTTP rule. The DaemonSet shows the same number in `READY` and `DESIRED`.

## Step 4: Write the values

```sh
kubectl -n starfleet create configmap migration-inventory --from-literal=injected-namespaces=outpost --from-literal=sidecar-pods=1 --from-literal=l7-policies=1 --from-literal=envoy-ready=yes --dry-run=client -o yaml | kubectl apply -f -
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-03/labs/lab-01 --keep
```

## Why this is the answer

A migration plan starts with an inventory. The injection label tells you which namespaces would still get new sidecars, the sidecar pods are what you must remove, the Layer 7 policies are what the node proxy must carry afterwards, and a ready node proxy is the condition to begin.
