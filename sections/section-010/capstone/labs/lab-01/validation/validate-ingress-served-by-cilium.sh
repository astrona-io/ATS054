#!/usr/bin/env bash
set -uo pipefail
class="$(kubectl -n starfleet get ingress scout -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)"
if [ "$class" != "cilium" ]; then echo "FAIL: ingressClassName is '$class', expected cilium"; exit 1; fi
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
NODE_PORT=""
for i in $(seq 1 30); do
  NODE_PORT="$(kubectl -n starfleet get service cilium-ingress-scout -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)"
  [ -n "$NODE_PORT" ] && break
  sleep 2
done
if [ -z "$NODE_PORT" ]; then echo "FAIL: Cilium did not create the Service cilium-ingress-scout"; exit 1; fi
out="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -w '\n%{http_code}' -H 'Host: scout.example.com' "http://$NODE_IP:$NODE_PORT/" 2>/dev/null)"
if echo "$out" | grep -qi podinfo && echo "$out" | tail -n 1 | grep -q '^200$'; then
  echo "PASS: the Ingress serves scout.example.com through Cilium"
  exit 0
fi
echo "FAIL: scout.example.com did not return the scout reply with status 200"
exit 1
