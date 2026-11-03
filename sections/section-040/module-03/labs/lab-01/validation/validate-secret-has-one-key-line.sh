#!/usr/bin/env bash
set -uo pipefail
keys() { kubectl -n kube-system get secret cilium-ipsec-keys -o jsonpath='{.data.keys}' 2>/dev/null | base64 -d 2>/dev/null; }
# Check: The Secret has the key keys with one key line of four fields
k="$(keys)"
n="$(echo "$k" | awk 'NF>0{c++} END{print c+0}')"
f="$(echo "$k" | awk 'NF>0{print NF; exit}')"
if [ "$n" = "1" ] && [ "$f" = "4" ]; then echo "PASS: one key line with four fields"; exit 0; fi
echo "FAIL: found $n lines and $f fields, expected 1 line and 4 fields"
exit 1
