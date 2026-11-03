#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
fail=0
p="$(code_drifter http://probe.starfleet.svc/get)"
s="$(code_drifter http://scout.starfleet.svc/)"
[ "$p" = "000" ] || { echo "FAIL: drifter reached probe with status '$p', expected no reply"; fail=1; }
[ "$s" = "200" ] || { echo "FAIL: drifter reached scout with status '$s', expected 200"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: drifter is blocked from probe and still reaches scout"
exit "$fail"
