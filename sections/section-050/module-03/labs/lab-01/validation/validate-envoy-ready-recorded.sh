#!/usr/bin/env bash
set -uo pipefail
cm() { kubectl -n starfleet get configmap migration-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key envoy-ready is yes when every cilium-envoy pod is ready
have="$(cm envoy-ready)"
want="$(d="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)"; r="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.numberReady}' 2>/dev/null)"; if [ -n "$d" ] && [ "$d" != "0" ] && [ "$d" = "$r" ]; then echo yes; else echo no; fi)"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: envoy-ready is '$have'"; exit 0; fi
echo "FAIL: envoy-ready in the ConfigMap is '$have', the cluster says '$want'"
exit 1
