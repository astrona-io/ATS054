#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: A policy for probe has HTTP rules for /get and /status
paths="$(kubectl -n starfleet get cnp -o jsonpath='{.items[*].spec.ingress[*].toPorts[*].rules.http[*].path}' 2>/dev/null)"
if echo "$paths" | grep -q '/get' && echo "$paths" | grep -q '/status'; then echo "PASS: HTTP rules for /get and /status exist"; exit 0; fi
echo "FAIL: HTTP paths found: '$paths'"
exit 1
