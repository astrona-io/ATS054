#!/usr/bin/env bash
set -uo pipefail
accepted="$(kubectl -n starfleet get httproute probe -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
if [ "$accepted" = "True" ]; then echo "PASS: the HTTPRoute probe is accepted by the Gateway edge-gw"; exit 0; fi
echo "FAIL: Accepted is '$accepted' on the HTTPRoute probe"
exit 1
