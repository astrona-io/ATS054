# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-03/labs/lab-01
```

## Step 1: Read the CRD annotations

The Gateway API CRDs carry their release channel and bundle version as annotations:

```sh
kubectl get crd gateways.gateway.networking.k8s.io -o yaml | grep 'gateway.networking.k8s.io/'
```

The annotation `gateway.networking.k8s.io/channel` is the channel, and `gateway.networking.k8s.io/bundle-version` is the version.

## Step 2: Read the class and the CRD list

```sh
kubectl get gatewayclass cilium -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}'; echo
kubectl get crd | grep gateway.networking.k8s.io
```

## Step 3: Write the values

```sh
CH=$(kubectl get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations.gateway\.networking\.k8s\.io/channel}')
BV=$(kubectl get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}')
AC=$(kubectl get gatewayclass cilium -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}')
if kubectl get crd tlsroutes.gateway.networking.k8s.io >/dev/null 2>&1; then TR=yes; else TR=no; fi
kubectl -n starfleet create configmap gateway-inventory --from-literal=channel=$CH --from-literal=bundle-version=$BV --from-literal=class-accepted=$AC --from-literal=has-tlsroute=$TR --dry-run=client -o yaml | kubectl apply -f -
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-03/labs/lab-01 --keep
```

## Why this is the answer

The channel decides which kinds exist: the experimental channel includes kinds such as `TLSRoute` that the standard channel does not. The bundle version tells you which fields you may use. The class status tells you that a controller has taken the class.
