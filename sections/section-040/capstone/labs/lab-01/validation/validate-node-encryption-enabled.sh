#!/usr/bin/env bash
set -uo pipefail
v="$(kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.encrypt-node}' 2>/dev/null)"
if [ "$v" = "true" ]; then echo "PASS: encrypt-node is true"; exit 0; fi
echo "FAIL: encrypt-node is '$v', expected true"
exit 1
