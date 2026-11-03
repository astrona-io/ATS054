#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}' 2>/dev/null)"
# Check: an HTTPS request for scout.example.com reaches scout.
if [ -z "$NODE_IP" ] || [ -z "$HTTPS_PORT" ]; then echo "FAIL: no node address or no node port 443 on cilium-gateway-fleet"; exit 1; fi
out="$(kubectl -n starfleet exec deploy/shuttle -- curl -sk -m 8 -w '\n%{http_code}' \
  --resolve "scout.example.com:$HTTPS_PORT:$NODE_IP" "https://scout.example.com:$HTTPS_PORT/" 2>/dev/null)"
if echo "$out" | grep -qi podinfo && echo "$out" | tail -n 1 | grep -q '^200$'; then
  echo "PASS: HTTPS for scout.example.com reaches scout"; exit 0
fi
echo "FAIL: an HTTPS request for scout.example.com did not return the scout reply with status 200"
exit 1
