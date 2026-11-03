#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: drifter in another namespace does not reach scout
code="$(code_drifter http://scout.starfleet.svc/)"
if [ "$code" != "200" ]; then echo "PASS: drifter is denied (code '$code')"; exit 0; fi
echo "FAIL: drifter got 200 from scout"
exit 1
