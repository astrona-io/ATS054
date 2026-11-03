#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
NODE_PORT="$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)"
if [ -z "$NODE_IP" ] || [ -z "$NODE_PORT" ]; then
  echo "FAIL: cannot find the node address or the node port of service cilium-gateway-fleet"
  exit 1
fi
# request HOST PATH [extra curl args]: prints the HTTP status code, then the body on the next lines
request() {
  local host="$1" path="$2"; shift 2
  kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -w '\n%{http_code}' -H "Host: $host" "$@" "http://$NODE_IP:$NODE_PORT$path" 2>/dev/null
}
out="$(request fleet.example.com /)"
if echo "$out" | grep -qi podinfo && echo "$out" | tail -n 1 | grep -q '^200$'; then
  echo "PASS: fleet.example.com reaches scout"
  exit 0
fi
echo "FAIL: a request for fleet.example.com did not return the scout reply with status 200"
exit 1
