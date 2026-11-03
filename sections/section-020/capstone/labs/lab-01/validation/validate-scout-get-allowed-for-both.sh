#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
fail=0
a="$(code_shuttle http://scout.starfleet.svc/)"
b="$(code_drifter http://scout.starfleet.svc/)"
[ "$a" = "200" ] || { echo "FAIL: GET / from shuttle returned '$a', expected 200"; fail=1; }
[ "$b" = "200" ] || { echo "FAIL: GET / from drifter returned '$b', expected 200"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: shuttle and drifter can GET scout"
exit "$fail"
