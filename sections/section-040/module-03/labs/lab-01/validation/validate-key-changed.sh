#!/usr/bin/env bash
set -uo pipefail
keys() { kubectl -n kube-system get secret cilium-ipsec-keys -o jsonpath='{.data.keys}' 2>/dev/null | base64 -d 2>/dev/null; }
# Check: The key differs from the old key
k="$(keys | awk 'NF>0{print $3; exit}')"
if [ -n "$k" ] && [ "$k" != "0123456789abcdef0123456789abcdef01234567" ]; then echo "PASS: the key is new"; exit 0; fi
echo "FAIL: the key is empty or the same as the old key"
exit 1
