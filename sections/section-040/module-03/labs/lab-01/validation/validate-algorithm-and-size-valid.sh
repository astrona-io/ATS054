#!/usr/bin/env bash
set -uo pipefail
keys() { kubectl -n kube-system get secret cilium-ipsec-keys -o jsonpath='{.data.keys}' 2>/dev/null | base64 -d 2>/dev/null; }
# Check: The algorithm is rfc4106(gcm(aes)), the key is 40 hex characters and the ICV size is 128
a="$(keys | awk 'NF>0{print $2; exit}')"
k="$(keys | awk 'NF>0{print $3; exit}')"
i="$(keys | awk 'NF>0{print $4; exit}')"
if [ "$a" = "rfc4106(gcm(aes))" ] && echo "$k" | grep -Eq '^[0-9a-fA-F]{40}$' && [ "$i" = "128" ]; then echo "PASS: algorithm, key length and ICV size are valid"; exit 0; fi
echo "FAIL: algorithm '$a', key '$k', ICV '$i'"
exit 1
