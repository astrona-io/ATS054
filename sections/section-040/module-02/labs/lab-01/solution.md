# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-02/labs/lab-01
```

## Step 1: Read the encryption line

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep '^Encryption'
```

The line has the form `Encryption: Wireguard [NodeEncryption: Disabled, cilium_wg0 (Pubkey: ..., Port: 51871, Peers: 1)]`. The device name, the port, the peer count and the node encryption state are all in it. You can also run `cilium-dbg encrypt status` for a longer view.

## Step 2: Write the values

Replace the values with what your line says. For the default values of this lab:

```sh
kubectl -n starfleet create configmap encryption-report --from-literal=interface=cilium_wg0 --from-literal=port=51871 --from-literal=peers=1 --from-literal=node-encryption=Disabled --dry-run=client -o yaml | kubectl apply -f -
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-02/labs/lab-01 --keep
```

## Why this is the answer

The cluster has two nodes, so each agent has one peer. The default node encryption is off: only traffic between pods is encrypted. The device is named `cilium_wg0` and listens on UDP 51871 unless the settings say otherwise.
