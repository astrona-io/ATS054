#!/usr/bin/env bash
set -uo pipefail
accepted="$(kubectl -n outpost get httproute outpost-probe -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
if [ "$accepted" = "True" ]; then echo "FAIL: the route in outpost is accepted, but outpost must not attach"; exit 1; fi
echo "PASS: the route in outpost is not accepted"
exit 0
