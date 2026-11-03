#!/usr/bin/env bash
set -uo pipefail
crdann() { kubectl get crd "$1" -o "jsonpath={.metadata.annotations.$2}" 2>/dev/null; }
cm() { kubectl -n starfleet get configmap gateway-inventory -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key bundle-version matches the installed bundle version
have="$(cm bundle-version)"
want="$(crdann gateways.gateway.networking.k8s.io 'gateway\.networking\.k8s\.io/bundle-version' )"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: bundle-version is '$have'"; exit 0; fi
echo "FAIL: bundle-version in the ConfigMap is '$have', the cluster says '$want'"
exit 1
