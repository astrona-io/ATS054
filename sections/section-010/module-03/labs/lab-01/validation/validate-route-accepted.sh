#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}' 2>/dev/null)"
# Check: the route is accepted by the https listener.
acc="$(kubectl -n starfleet get httproute scout -o jsonpath='{.status.parents[*].conditions[?(@.type=="Accepted")].status}' 2>/dev/null)"
if [ "$acc" = "True" ]; then echo "PASS: the route is accepted"; exit 0; fi
echo "FAIL: Accepted on the route is '$acc'"
exit 1
