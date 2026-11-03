#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap architecture-report -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key sidecar-webhooks is the number of mutating webhooks whose name has istio or linkerd
have="$(cm sidecar-webhooks)"
want="$(kubectl get mutatingwebhookconfigurations -o name 2>/dev/null | { grep -ciE 'istio|linkerd' || true; } | tr -d ' ')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: sidecar-webhooks is '$have'"; exit 0; fi
echo "FAIL: sidecar-webhooks in the ConfigMap is '$have', the cluster says '$want'"
exit 1
