#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: GET /uuid is denied with 403
code="$(code_shuttle http://probe.starfleet.svc/uuid)"
if [ "$code" = "403" ]; then echo "PASS: GET /uuid is denied with 403"; exit 0; fi
echo "FAIL: GET /uuid returned '$code', expected 403"
exit 1
