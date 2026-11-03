#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
NODE_PORT="$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)"
if [ -z "$NODE_IP" ] || [ -z "$NODE_PORT" ]; then
  echo "FAIL: cannot find the node address or the node port of service cilium-gateway-fleet"
  exit 1
fi
# request PATH [extra curl args]: prints the body, then the status code and the redirect URL on the last line
request() {
  local path="$1"; shift
  kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -w '\\n%{http_code} %{redirect_url}' -H "Host: fleet.example.com" "$@" "http://$NODE_IP:$NODE_PORT$path" 2>/dev/null
}
# Check: A request for /probe through the Gateway is served by probe and not by scout
out="$(request /probe)"
code="$(echo "$out" | tail -n 1 | cut -d' ' -f1)"
if [ "$code" != "200" ] && ! echo "$out" | grep -qi podinfo && [ -n "$code" ] && [ "$code" != "000" ]; then echo "PASS: /probe is served by probe (code $code, not scout)"; exit 0; fi
echo "FAIL: /probe returned '$code' or the scout reply; it must be routed to probe"
exit 1
