#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}' 2>/dev/null)"
# Check: the listener keeps its port, host name and TLS mode.
port="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[0].port}' 2>/dev/null)"
host="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[0].hostname}' 2>/dev/null)"
mode="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[0].tls.mode}' 2>/dev/null)"
count="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.spec.listeners[*].name}' 2>/dev/null | wc -w | tr -d ' ')"
if [ "$port" = "443" ] && [ "$host" = "scout.example.com" ] && [ "$mode" = "Terminate" ] && [ "$count" = "1" ]; then
  echo "PASS: the listener is unchanged except for the certificate"; exit 0
fi
echo "FAIL: port '$port', hostname '$host', mode '$mode', listeners '$count'"
exit 1
