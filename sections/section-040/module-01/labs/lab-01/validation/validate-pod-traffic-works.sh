#!/usr/bin/env bash
set -uo pipefail
fail=0
a="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}' http://scout.starfleet.svc/ 2>/dev/null)"
b="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}' http://probe.starfleet.svc/get 2>/dev/null)"
c="$(kubectl -n outpost exec deploy/drifter -- curl -s -m 10 -o /dev/null -w '%{http_code}' http://scout.starfleet.svc/ 2>/dev/null)"
[ "$a" = "200" ] || { echo "FAIL: shuttle to scout returned '$a'"; fail=1; }
[ "$b" = "200" ] || { echo "FAIL: shuttle to probe returned '$b'"; fail=1; }
[ "$c" = "200" ] || { echo "FAIL: drifter to scout returned '$c'"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: pods still reach each other"
exit "$fail"
