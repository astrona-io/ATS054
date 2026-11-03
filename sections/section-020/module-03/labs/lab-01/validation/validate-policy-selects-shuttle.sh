#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: A CiliumNetworkPolicy in starfleet selects the pods with app=shuttle
sel="$(kubectl -n starfleet get cnp -o jsonpath='{.items[*].spec.endpointSelector.matchLabels.app}' 2>/dev/null)"
if echo " $sel " | grep -q ' shuttle '; then echo "PASS: a policy selects shuttle"; exit 0; fi
echo "FAIL: no CiliumNetworkPolicy in starfleet selects app=shuttle (found: '$sel')"
exit 1
