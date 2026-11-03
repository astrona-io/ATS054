---
draft: true
---
# The Key Secret

All the IPsec setup you do by hand is one Secret. Its format is strict, and an error in it is the most common cause of an agent that does not start encryption.

## The key line

The Secret has the key `keys`. Its value is one line of four fields separated by spaces:

```text
3+ rfc4106(gcm(aes)) 0123456789abcdef0123456789abcdef01234567 128
```

| Field | Meaning |
| --- | --- |
| `3+` | The SPI. The plus sign makes Cilium derive a separate key for each pair of nodes from the one you give. |
| `rfc4106(gcm(aes))` | The algorithm: AES in GCM mode, which encrypts and authenticates. |
| the long hex string | The key and the salt: 20 bytes, written as 40 hexadecimal characters for AES-128. |
| `128` | The size of the integrity check value (ICV) in bits. |

Use other algorithms and key sizes only when the Cilium documentation of your version lists them.

## Create it

<!-- astrona:playground:renew -->

```sh
KEY=$(dd if=/dev/urandom count=20 bs=1 2>/dev/null | xxd -p -c 64)
echo "$KEY" | wc -c
kubectl -n kube-system create secret generic demo-ipsec-keys \
  --from-literal=keys="1+ rfc4106(gcm(aes)) $KEY 128" --dry-run=client -o yaml
```

The count prints 41 (40 characters and a newline). The dry run prints the Secret without creating it. Create it for real only when you enable IPsec, under the name that your Helm values use.

## Install with it

```sh
helm upgrade --install cilium cilium/cilium -n kube-system \
  --reuse-values \
  --set encryption.enabled=true \
  --set encryption.type=ipsec
```

The chart finds the Secret by its default name. Restart the agents if you change the Secret without a chart upgrade.

## Protect the key

Anyone who can read the Secret can decrypt the traffic. Limit read access to the Secret with RBAC, enable encryption at rest for Secrets in the API server and keep the key out of your Git history. Do not paste real keys into a ticket or a chat.

## Common pitfalls

> [!WARNING]
> A key line with a wrong length, a missing field or Windows line endings is rejected, and the log of the agent names the problem. Check the length with `wc -c` before you apply, and read the agent log after.
