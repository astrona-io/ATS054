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
# Check: The Gateway listener is unchanged
host="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[0].hostname}' 2>/dev/null)"
name="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[0].name}' 2>/dev/null)"
if [ "$host" = "*.example.com" ] && [ "$name" = "web" ]; then echo "PASS: the Gateway is unchanged"; exit 0; fi
echo "FAIL: the listener is '$name' with host '$host'"
exit 1
