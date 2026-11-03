#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}' 2>/dev/null)"
HTTP_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}' 2>/dev/null)"
if [ -z "$NODE_IP" ] || [ -z "$HTTP_PORT" ]; then
  echo "FAIL: cannot find the node address or the node port of service cilium-ingress-scout"
  exit 1
fi
# Check: the Ingress references an existing TLS Secret.
secret="$(kubectl -n starfleet get ingress scout -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)"
if [ -z "$secret" ]; then echo "FAIL: the Ingress has no tls entry"; exit 1; fi
if ! kubectl -n starfleet get secret "$secret" >/dev/null 2>&1; then
  echo "FAIL: the Ingress names the Secret '$secret', which does not exist in starfleet"
  exit 1
fi
echo "PASS: the Ingress names the existing TLS Secret '$secret'"
