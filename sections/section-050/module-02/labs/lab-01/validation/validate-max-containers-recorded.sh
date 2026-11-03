#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap architecture-report -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key max-containers is the largest number of containers in one pod of starfleet and outpost
have="$(cm max-containers)"
want="$(for ns in starfleet outpost; do kubectl -n $ns get pods -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}' 2>/dev/null; done | awk '{ if (NF>m) m=NF } END { print m+0 }')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: max-containers is '$have'"; exit 0; fi
echo "FAIL: max-containers in the ConfigMap is '$have', the cluster says '$want'"
exit 1
