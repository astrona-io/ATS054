#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
ann() { kubectl -n starfleet get service probe-lb -o "jsonpath={.metadata.annotations.$1}" 2>/dev/null; }
# Check: A request to probe-lb from shuttle returns 200
code="$(code_shuttle http://probe-lb.starfleet.svc/get)"
if [ "$code" = "200" ]; then echo "PASS: probe-lb answers with 200"; exit 0; fi
echo "FAIL: GET /get on probe-lb returned '$code', expected 200"
exit 1
