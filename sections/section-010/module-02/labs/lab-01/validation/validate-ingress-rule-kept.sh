#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}' 2>/dev/null)"
HTTP_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}' 2>/dev/null)"
if [ -z "$NODE_IP" ] || [ -z "$HTTP_PORT" ]; then
  echo "FAIL: cannot find the node address or the node port of service cilium-ingress-scout"
  exit 1
fi
# Check: the Ingress keeps its host rule and the class cilium.
host="$(kubectl -n starfleet get ingress scout -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)"
class="$(kubectl -n starfleet get ingress scout -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)"
backend="$(kubectl -n starfleet get ingress scout -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)"
if [ "$host" = "scout.example.com" ] && [ "$class" = "cilium" ] && [ "$backend" = "scout" ]; then
  echo "PASS: the Ingress keeps its host, its class and its backend"
  exit 0
fi
echo "FAIL: host is '$host', class is '$class', backend is '$backend'"
exit 1
