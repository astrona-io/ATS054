#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap migration-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key injected-namespaces lists the namespaces with the injection label
have="$(cm injected-namespaces)"
want="$(kubectl get namespaces -l sidecar.example.io/inject=true -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: injected-namespaces is '$have'"; exit 0; fi
echo "FAIL: injected-namespaces in the ConfigMap is '$have', the cluster says '$want'"
exit 1
