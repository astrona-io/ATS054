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
with="$(request fleet.example.com /uuid -H 'x-fleet: probe' | tail -n 1)"
without="$(request fleet.example.com /uuid | tail -n 1)"
fail=0
if [ "$with" != "200" ]; then echo "FAIL: /uuid with x-fleet: probe returned '$with', expected 200 from probe"; fail=1; fi
if [ "$without" = "200" ]; then echo "FAIL: /uuid without the header returned 200, so it also reached probe"; fail=1; fi
[ "$fail" -eq 0 ] && echo "PASS: the header selects probe and other requests go to scout"
exit "$fail"
