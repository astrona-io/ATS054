#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
a="$(code_shuttle -X POST http://scout.starfleet.svc/)"
b="$(code_drifter -X POST http://scout.starfleet.svc/)"
if [ "$a" = "403" ] && [ "$b" = "403" ]; then echo "PASS: POST to scout is answered with 403"; exit 0; fi
echo "FAIL: POST returned '$a' from shuttle and '$b' from drifter, expected 403 for both"
exit 1
