#!/usr/bin/env bash
set -uo pipefail
crdann() { kubectl get crd "$1" -o "jsonpath={.metadata.annotations.$2}" 2>/dev/null; }
cm() { kubectl -n starfleet get configmap gateway-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key class-accepted matches the Accepted condition of the GatewayClass cilium
have="$(cm class-accepted)"
want="$(kubectl get gatewayclass cilium -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: class-accepted is '$have'"; exit 0; fi
echo "FAIL: class-accepted in the ConfigMap is '$have', the cluster says '$want'"
exit 1
