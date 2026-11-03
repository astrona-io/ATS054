#!/usr/bin/env bash
set -uo pipefail
fail=0
pods="$(kubectl -n kube-system get pods -l k8s-app=cilium -o name 2>/dev/null)"
[ -n "$pods" ] || { echo "FAIL: no Cilium agent pods found"; exit 1; }
for p in $pods; do
  line="$(kubectl -n kube-system exec "$p" -c cilium-agent -- cilium-dbg status 2>/dev/null | grep -i 'Encryption')"
  if ! echo "$line" | grep -qi 'wireguard'; then echo "FAIL: $p reports '$line'"; fail=1; fi
done
[ "$fail" -eq 0 ] && echo "PASS: every agent reports WireGuard"
exit "$fail"
