#!/usr/bin/env bash
set -uo pipefail
fail=0
sel="$(kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.from}/{.spec.listeners[0].allowedRoutes.namespaces.selector.matchLabels.access}' 2>/dev/null)"
host="$(kubectl -n starfleet get ingress scout -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)"
if [ "$sel" != "Selector/gateway" ]; then echo "FAIL: the Gateway selector changed ($sel)"; fail=1; fi
if [ "$host" != "scout.example.com" ]; then echo "FAIL: the Ingress host changed ($host)"; fail=1; fi
[ "$fail" -eq 0 ] && echo "PASS: the Gateway selector and the Ingress rule are unchanged"
exit "$fail"
