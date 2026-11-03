#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
ann() { kubectl -n starfleet get service probe-lb -o "jsonpath={.metadata.annotations.$1}" 2>/dev/null; }
# Check: The Service probe-lb has the annotation service.cilium.io/lb-l7 set to enabled
v="$(ann 'service\.cilium\.io/lb-l7')"
if [ "$v" = "enabled" ]; then echo "PASS: lb-l7 is enabled"; exit 0; fi
echo "FAIL: the annotation service.cilium.io/lb-l7 is '$v', expected 'enabled'"
exit 1
