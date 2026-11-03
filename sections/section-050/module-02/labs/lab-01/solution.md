# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-02/labs/lab-01
```

## Step 1: Count the node-level pods

```sh
kubectl -n kube-system get pods -l k8s-app=cilium
kubectl -n kube-system get pods -l k8s-app=cilium-envoy
```

Each command lists one pod for each node. Count the lines.

## Step 2: Count the containers of the application pods

```sh
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CONTAINERS:.spec.containers[*].name | grep -E 'starfleet|outpost'
kubectl get mutatingwebhookconfigurations
```

Every application pod has one container. No sidecar injector webhook exists.

## Step 3: Write the values

For the two-node cluster of this lab:

```sh
kubectl -n starfleet create configmap architecture-report --from-literal=agent-pods=2 --from-literal=envoy-pods=2 --from-literal=max-containers=1 --from-literal=sidecar-webhooks=0 --dry-run=client -o yaml | kubectl apply -f -
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-02/labs/lab-01 --keep
```

## Why this is the answer

In a sidecarless design the proxy runs once for each node, in the `cilium-envoy` DaemonSet, and the application pods have no proxy container. The count of proxies follows the count of nodes, not the count of pods.
