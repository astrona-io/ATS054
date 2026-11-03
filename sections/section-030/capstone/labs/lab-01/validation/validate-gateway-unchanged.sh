#!/usr/bin/env bash
set -uo pipefail
sel="$(kubectl -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.from}/{.spec.listeners[0].allowedRoutes.namespaces.selector.matchLabels.access}' 2>/dev/null)"
if [ "$sel" = "Selector/gateway" ]; then echo "PASS: the Gateway selector is unchanged"; exit 0; fi
echo "FAIL: the Gateway selector changed ($sel)"
exit 1
