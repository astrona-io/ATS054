#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap migration-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key l7-policies counts the CiliumNetworkPolicy objects with an HTTP rule
have="$(cm l7-policies)"
want="$(for ns in starfleet outpost; do kubectl -n $ns get cnp -o jsonpath='{range .items[*]}{.spec.ingress[*].toPorts[*].rules.http[*].method}{"\n"}{end}' 2>/dev/null; done | { grep -c . || true; } | tr -d ' ')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: l7-policies is '$have'"; exit 0; fi
echo "FAIL: l7-policies in the ConfigMap is '$have', the cluster says '$want'"
exit 1
