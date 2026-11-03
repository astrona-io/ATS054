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
  kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -w '\n%{http_code} %{redirect_url}' -H "Host: fleet.example.com" "$@" "http://$NODE_IP:$NODE_PORT$path" 2>/dev/null
}
# Check: A request for /old/page gets a 301 redirect to probe.example.com
out="$(request /old/page | tail -n 1)"
code="${out%% *}"
if [ "$code" = "301" ] && echo "$out" | grep -q 'probe.example.com'; then echo "PASS: /old redirects with 301 to probe.example.com"; exit 0; fi
echo "FAIL: the last line was '$out', expected 301 and a redirect URL with probe.example.com"
exit 1
