#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: A policy for scout requires authentication in an ingress rule
modes="$(kubectl -n starfleet get cnp -o jsonpath='{.items[*].spec.ingress[*].authentication.mode}' 2>/dev/null)"
if echo "$modes" | grep -q 'required'; then echo "PASS: an ingress rule has authentication mode required"; exit 0; fi
echo "FAIL: authentication modes found: '$modes'"
exit 1
