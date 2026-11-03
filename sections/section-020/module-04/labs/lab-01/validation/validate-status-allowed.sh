#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: GET /status/204 from shuttle returns 204
code="$(code_shuttle http://probe.starfleet.svc/status/204)"
if [ "$code" = "204" ]; then echo "PASS: GET /status/204 returns 204"; exit 0; fi
echo "FAIL: GET /status/204 returned '$code', expected 204"
exit 1
