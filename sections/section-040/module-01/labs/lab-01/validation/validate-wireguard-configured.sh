#!/usr/bin/env bash
set -uo pipefail
v="$(kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.enable-wireguard}' 2>/dev/null)"
if [ "$v" = "true" ]; then echo "PASS: enable-wireguard is true"; exit 0; fi
echo "FAIL: enable-wireguard is '$v', expected true"
exit 1
