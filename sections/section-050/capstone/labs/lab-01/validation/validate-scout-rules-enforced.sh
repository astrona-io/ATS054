#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
fail=0
a="$(code_shuttle http://scout.starfleet.svc/)"
b="$(code_shuttle -X POST http://scout.starfleet.svc/)"
c="$(code_drifter http://scout.starfleet.svc/)"
[ "$a" = "200" ] || { echo "FAIL: GET / from shuttle returned '$a', expected 200"; fail=1; }
[ "$b" = "403" ] || { echo "FAIL: POST / from shuttle returned '$b', expected 403"; fail=1; }
[ "$c" = "000" ] || { echo "FAIL: drifter reached scout with status '$c', expected no reply"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: scout accepts GET from shuttle only"
exit "$fail"
