#!/usr/bin/env bash
set -uo pipefail
fail=0
accepted="$(kubectl -n outpost get httproute probe -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
resolved="$(kubectl -n outpost get httproute probe -o jsonpath='{.status.parents[*].conditions[?(@.type=="ResolvedRefs")].status}' 2>/dev/null)"
[ "$accepted" = "True" ] || { echo "FAIL: Accepted is '$accepted'"; fail=1; }
[ "$resolved" = "True" ] || { echo "FAIL: ResolvedRefs is '$resolved'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the route is accepted and its backend resolves"
exit "$fail"
