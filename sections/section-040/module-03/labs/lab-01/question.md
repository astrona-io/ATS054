# Question

Solve this question on: `terminal`

The team prepares to use IPsec. The Secret `cilium-ipsec-keys` in the namespace `kube-system` holds the current key with SPI 1. Rotate it: replace the value of the key `keys` with one new key line.

1. The SPI is 2. Keep the plus sign after it, so the line starts with `2+`.
2. The algorithm is `rfc4106(gcm(aes))`.
3. The key is new: 20 random bytes written as 40 hexadecimal characters. Do not reuse the old key.
4. The ICV size is `128`.
5. The Secret has one key line. Keep the name, the namespace and the key name `keys`.

This cluster runs without encryption, so the rotation only prepares the Secret. `kubectl` already points at the cluster.
