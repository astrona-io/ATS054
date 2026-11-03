#!/usr/bin/env bash
set -uo pipefail
from="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.from}' 2>/dev/null)"
count="$(kubectl get httproute -A --no-headers 2>/dev/null | grep -c .)"
if [ "$from" = "Same" ] && [ "$count" -eq 1 ]; then
  echo "PASS: the Gateway is unchanged and there is one HTTPRoute"
  exit 0
fi
echo "FAIL: allowedRoutes.namespaces.from is '$from' and there are $count HTTPRoute objects (expected Same and 1)"
exit 1
