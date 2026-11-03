#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: drifter in outpost still reaches probe
code="$(code_drifter http://probe.starfleet.svc/get)"
if [ "$code" = "200" ]; then echo "PASS: drifter still reaches probe"; exit 0; fi
echo "FAIL: drifter to probe returned '$code', expected 200"
exit 1
