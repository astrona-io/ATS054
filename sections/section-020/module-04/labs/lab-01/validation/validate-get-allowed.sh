#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: GET /get from shuttle returns 200
code="$(code_shuttle http://probe.starfleet.svc/get)"
if [ "$code" = "200" ]; then echo "PASS: GET /get returns 200"; exit 0; fi
echo "FAIL: GET /get returned '$code', expected 200"
exit 1
