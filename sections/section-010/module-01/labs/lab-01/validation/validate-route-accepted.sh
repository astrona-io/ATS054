#!/usr/bin/env bash
# Check: the HTTPRoute fleet is attached to a Gateway and its backends resolve.
set -uo pipefail
fail=0
accepted="$(kubectl -n starfleet get httproute fleet -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
resolved="$(kubectl -n starfleet get httproute fleet -o jsonpath='{.status.parents[*].conditions[?(@.type=="ResolvedRefs")].status}' 2>/dev/null)"
parent="$(kubectl -n starfleet get httproute fleet -o jsonpath='{.spec.parentRefs[0].name}' 2>/dev/null)"
if [ "$accepted" != "True" ]; then echo "FAIL: Accepted is '$accepted' (parentRef is '$parent')"; fail=1; fi
if [ "$resolved" != "True" ]; then echo "FAIL: ResolvedRefs is '$resolved'"; fail=1; fi
[ "$fail" -eq 0 ] && echo "PASS: the HTTPRoute is accepted and its references resolve"
exit "$fail"
