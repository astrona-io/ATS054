#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
code_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
# Check: shuttle reaches scout and gets 200 after the authentication
for i in 1 2 3 4 5 6; do
  code="$(code_shuttle http://scout.starfleet.svc/)"
  if [ "$code" = "200" ]; then echo "PASS: shuttle gets 200 from scout"; exit 0; fi
  sleep 5
done
echo "FAIL: shuttle to scout returned '$code', expected 200"
exit 1
