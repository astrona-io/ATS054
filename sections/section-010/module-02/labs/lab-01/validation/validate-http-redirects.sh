#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}' 2>/dev/null)"
HTTP_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}' 2>/dev/null)"
if [ -z "$NODE_IP" ] || [ -z "$HTTP_PORT" ]; then
  echo "FAIL: cannot find the node address or the node port of service cilium-ingress-scout"
  exit 1
fi
# Check: a plain HTTP request for scout.example.com is redirected to HTTPS.
code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 8 -o /dev/null -w '%{http_code}' \
  -H 'Host: scout.example.com' "http://$NODE_IP:$HTTP_PORT/" 2>/dev/null)"
case "$code" in
  301|302|307|308) echo "PASS: HTTP is redirected with status $code"; exit 0 ;;
esac
echo "FAIL: a plain HTTP request returned '$code', expected a redirect status"
exit 1
