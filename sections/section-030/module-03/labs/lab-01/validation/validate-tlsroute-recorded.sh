#!/usr/bin/env bash
set -uo pipefail
crdann() { kubectl get crd "$1" -o "jsonpath={.metadata.annotations.$2}" 2>/dev/null; }
cm() { kubectl -n starfleet get configmap gateway-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key has-tlsroute is yes when the CRD tlsroutes exists and no when it does not
have="$(cm has-tlsroute)"
want="$(if kubectl get crd tlsroutes.gateway.networking.k8s.io >/dev/null 2>&1; then echo yes; else echo no; fi)"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: has-tlsroute is '$have'"; exit 0; fi
echo "FAIL: has-tlsroute in the ConfigMap is '$have', the cluster says '$want'"
exit 1
