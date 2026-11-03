#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
fail=0
a="$(code_shuttle http://probe.starfleet.svc/uuid)"
b="$(code_shuttle -X POST http://probe.starfleet.svc/post)"
[ "$a" = "403" ] || { echo "FAIL: GET /uuid returned '$a', expected 403 from Envoy"; fail=1; }
[ "$b" = "403" ] || { echo "FAIL: POST /post returned '$b', expected 403 from Envoy"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: other requests from shuttle get 403"
exit "$fail"
