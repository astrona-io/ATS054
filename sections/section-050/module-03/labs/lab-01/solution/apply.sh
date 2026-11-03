#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
NS="$(kubectl get namespaces -l sidecar.example.io/inject=true -o jsonpath='{.items[*].metadata.name}')"
SP="$(for ns in starfleet outpost; do kubectl -n $ns get pods -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}'; done | { grep -cw proxy || true; } | tr -d ' ')"
LP="$(for ns in starfleet outpost; do kubectl -n $ns get cnp -o jsonpath='{range .items[*]}{.spec.ingress[*].toPorts[*].rules.http[*].method}{"\n"}{end}'; done | { grep -c . || true; } | tr -d ' ')"
d="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.desiredNumberScheduled}')"
r="$(kubectl -n kube-system get daemonset cilium-envoy -o jsonpath='{.status.numberReady}')"
if [ "$d" != "0" ] && [ "$d" = "$r" ]; then ER=yes; else ER=no; fi
kubectl -n starfleet create configmap migration-inventory --from-literal=injected-namespaces="$NS" --from-literal=sidecar-pods="$SP" --from-literal=l7-policies="$LP" --from-literal=envoy-ready="$ER" --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
