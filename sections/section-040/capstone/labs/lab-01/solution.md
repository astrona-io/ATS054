# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Read the current values

```sh
helm -n kube-system get values cilium
kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.encrypt-node}{"\n"}'
```

The release sets `encryption.enabled` and `encryption.type`, and the ConfigMap value `encrypt-node` is `false`.

## Step 2: Add the repository and upgrade

`--reuse-values` keeps the values that the release already has. Add the repository, then upgrade:

```sh
helm repo add cilium https://helm.cilium.io/
helm repo update
helm -n kube-system upgrade cilium cilium/cilium --version 1.20.2 --reuse-values --set encryption.nodeEncryption=true --wait --timeout 300s
```

Then wait for the agents and submit:

```sh
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/capstone/labs/lab-01 --keep
```

## Step 3: Test by hand

```sh
kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.encrypt-node}{"\n"}'
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep Encryption
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The ConfigMap value is `true`, the status line still names WireGuard, and the request returns `200`.

## Why this is the answer

The Helm value `encryption.nodeEncryption=true` writes `encrypt-node: "true"` into the ConfigMap, and the agents read it when they restart. Without `--reuse-values`, Helm resets the other values to the chart defaults, which would also turn WireGuard and the API server address back to defaults. The option is only effective when the type is `wireguard`, and the nodes with the control-plane label are excluded by default.
