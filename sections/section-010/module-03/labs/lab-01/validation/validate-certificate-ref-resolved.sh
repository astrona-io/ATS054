#!/usr/bin/env bash
set -uo pipefail
NODE_IP="$(kubectl get node -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)"
HTTPS_PORT="$(kubectl -n starfleet get service cilium-gateway-fleet -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}' 2>/dev/null)"
# Check: the certificate reference of the https listener resolves.
status="$(kubectl -n starfleet get gateway fleet -o jsonpath='{.status.listeners[?(@.name=="https")].conditions[?(@.type=="ResolvedRefs")].status}' 2>/dev/null)"
if [ "$status" = "True" ]; then echo "PASS: the certificate reference resolves"; exit 0; fi
echo "FAIL: ResolvedRefs of the https listener is '$status'"
exit 1
