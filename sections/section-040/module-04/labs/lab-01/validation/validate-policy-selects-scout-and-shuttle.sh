#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: The policy selects scout and accepts shuttle
sel="$(kubectl -n starfleet get cnp -o jsonpath='{.items[*].spec.endpointSelector.matchLabels.app}' 2>/dev/null)"
from="$(kubectl -n starfleet get cnp -o jsonpath='{.items[*].spec.ingress[*].fromEndpoints[*].matchLabels.app}' 2>/dev/null)"
if echo "$sel" | grep -q 'scout' && echo "$from" | grep -q 'shuttle'; then echo "PASS: the policy selects scout and accepts shuttle"; exit 0; fi
echo "FAIL: selector '$sel', from '$from'"
exit 1
