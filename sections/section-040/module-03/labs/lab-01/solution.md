# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-03/labs/lab-01
```

## Step 1: Read the old key

```sh
kubectl -n kube-system get secret cilium-ipsec-keys -o jsonpath='{.data.keys}' | base64 -d; echo
```

The line has four fields: `1+`, the algorithm, the key and the ICV size.

## Step 2: Build the new line

Make a new random key of 20 bytes as 40 hex characters. Then write the line with SPI 2:

```sh
KEY=$(dd if=/dev/urandom count=20 bs=1 2>/dev/null | xxd -p -c 64)
kubectl -n kube-system create secret generic cilium-ipsec-keys --from-literal=keys="2+ rfc4106(gcm(aes)) $KEY 128" --dry-run=client -o yaml | kubectl apply -f -
```

Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-03/labs/lab-01 --keep
```

## Why this is the answer

Rotation replaces the old key with a key that has the next SPI. The agents compare the SPI to the one they use and switch to the new key. The plus sign selects per-node-pair keys that are derived from the one you give. A key that is not 40 hex characters is rejected by the agents.
