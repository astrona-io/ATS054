#!/usr/bin/env bash
set -uo pipefail
desired="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)"
ready="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.numberReady}' 2>/dev/null)"
if [ -z "$desired" ] || [ "$desired" -lt 1 ] || [ "$desired" != "$ready" ]; then echo "FAIL: cilium-envoy desired='$desired' ready='$ready'"; exit 1; fi
fail=0
for name in scout probe; do
  ready="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
  want="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.replicas}' 2>/dev/null)"
  [ -n "$ready" ] && [ "$ready" = "$want" ] || { echo "FAIL: deployment $name ready='$ready' expected='$want'"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: the node proxy and the pods are healthy"
exit "$fail"
