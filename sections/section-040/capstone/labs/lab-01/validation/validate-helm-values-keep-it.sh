#!/usr/bin/env bash
set -uo pipefail
values="$(helm -n kube-system get values cilium -o json 2>/dev/null)"
fail=0
echo "$values" | tr -d ' \n' | grep -q '"nodeEncryption":true' || { echo "FAIL: the Helm release does not set encryption.nodeEncryption=true"; fail=1; }
echo "$values" | tr -d ' \n' | grep -q '"type":"wireguard"' || { echo "FAIL: the Helm release does not keep encryption.type=wireguard"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the Helm release holds both values"
exit "$fail"
