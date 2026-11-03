#!/usr/bin/env bash
set -uo pipefail
fail=0
from="$(kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.from}' 2>/dev/null)"
label="$(kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.selector.matchLabels.access}' 2>/dev/null)"
out="$(kubectl get namespace outpost -o jsonpath='{.metadata.labels.access}' 2>/dev/null)"
[ "$from" = "Selector" ] || { echo "FAIL: allowedRoutes from is '$from', expected Selector"; fail=1; }
[ "$label" = "gateway" ] || { echo "FAIL: the selector label access is '$label', expected gateway"; fail=1; }
[ "$out" != "gateway" ] || { echo "FAIL: the namespace outpost carries access=gateway"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the listener selects the label access=gateway and outpost is not labelled"
exit "$fail"
