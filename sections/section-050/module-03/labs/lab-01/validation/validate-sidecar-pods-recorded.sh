#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap migration-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key sidecar-pods counts the pods that have a container named proxy
have="$(cm sidecar-pods)"
want="$(for ns in starfleet outpost; do kubectl -n $ns get pods -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}' 2>/dev/null; done | { grep -cw proxy || true; } | tr -d ' ')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: sidecar-pods is '$have'"; exit 0; fi
echo "FAIL: sidecar-pods in the ConfigMap is '$have', the cluster says '$want'"
exit 1
