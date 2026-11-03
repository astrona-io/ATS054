#!/usr/bin/env bash
set -uo pipefail
accepted="$(kubectl -n starfleet get httproute scout -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
if [ "$accepted" = "True" ]; then echo "PASS: the HTTPRoute scout is accepted by edge-gw"; exit 0; fi
echo "FAIL: Accepted is '$accepted' on the HTTPRoute scout"
exit 1
