#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
ann() { kubectl -n starfleet get service probe-lb -o "jsonpath={.metadata.annotations.$1}" 2>/dev/null; }
# Check: The Service still selects app=probe on port 80
sel="$(kubectl -n starfleet get service probe-lb -o jsonpath='{.spec.selector.app}' 2>/dev/null)"
port="$(kubectl -n starfleet get service probe-lb -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)"
if [ "$sel" = "probe" ] && [ "$port" = "80" ]; then echo "PASS: the selector and the port are unchanged"; exit 0; fi
echo "FAIL: selector is '$sel' and port is '$port'"
exit 1
