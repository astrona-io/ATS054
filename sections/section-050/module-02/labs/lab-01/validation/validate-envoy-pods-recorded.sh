#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap architecture-report -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key envoy-pods is the number of cilium-envoy pods
have="$(cm envoy-pods)"
want="$(kubectl -n kube-system get pods -l k8s-app=cilium-envoy --no-headers 2>/dev/null | wc -l | tr -d ' ')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: envoy-pods is '$have'"; exit 0; fi
echo "FAIL: envoy-pods in the ConfigMap is '$have', the cluster says '$want'"
exit 1
