# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-01/labs/lab-01
```

## Step 1: Read the current state

```sh
kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.enable-wireguard}{"\n"}'
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep Encryption
```

The ConfigMap value is `false`, and the status line does not name WireGuard.

## Step 2: Enable WireGuard in the ConfigMap

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"enable-wireguard":"true"}}'
```

## Step 3: Restart the agents

The agents read the ConfigMap when they start, so restart the DaemonSet and wait:

```sh
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-01/labs/lab-01 --keep
```

## Step 4: Test by hand

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep Encryption
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
kubectl -n outpost exec deploy/drifter -- curl -s -m 10 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The status line names WireGuard and the device `cilium_wg0`. Both requests return `200`. Packets can be dropped for a short time while the WireGuard device is configured, so repeat a request that fails once.

## Why this is the answer

The Helm values `encryption.enabled=true` and `encryption.type=wireguard` produce the key `enable-wireguard: "true"` in the ConfigMap. The agents read it at start, so a restart is needed. The change in the ConfigMap is not stored in the Helm release, so a later `helm upgrade` without the same values would turn it off. Production clusters change the Helm values.
