#!/usr/bin/env bash
set -uo pipefail
desired="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)"
ready="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.numberReady}' 2>/dev/null)"
if [ -n "$desired" ] && [ "$desired" -ge 1 ] && [ "$desired" = "$ready" ]; then echo "PASS: cilium-envoy is ready on $ready node(s)"; exit 0; fi
echo "FAIL: cilium-envoy desired='$desired' ready='$ready'"
exit 1
