#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: shuttle can no longer reach probe
code="$(code_shuttle http://probe.starfleet.svc/get)"
if [ "$code" != "200" ]; then echo "PASS: shuttle cannot reach probe (code '$code')"; exit 0; fi
echo "FAIL: shuttle still reaches probe with 200"
exit 1
