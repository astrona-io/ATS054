#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
fail=0
a="$(code_shuttle http://probe.starfleet.svc/get)"
b="$(code_shuttle http://probe.starfleet.svc/uuid)"
c="$(code_drifter http://probe.starfleet.svc/get)"
[ "$a" = "200" ] || { echo "FAIL: GET /get from shuttle returned '$a', expected 200"; fail=1; }
[ "$b" = "403" ] || { echo "FAIL: GET /uuid from shuttle returned '$b', expected 403"; fail=1; }
[ "$c" = "000" ] || { echo "FAIL: drifter reached probe with status '$c', expected no reply"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: probe accepts GET /get from shuttle only"
exit "$fail"
