#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
AP="$(kubectl -n kube-system get pods -l k8s-app=cilium --no-headers | wc -l | tr -d ' ')"
EP="$(kubectl -n kube-system get pods -l k8s-app=cilium-envoy --no-headers | wc -l | tr -d ' ')"
MC="$(for ns in starfleet outpost; do kubectl -n $ns get pods -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}'; done | awk '{ if (NF>m) m=NF } END { print m+0 }')"
SW="$(kubectl get mutatingwebhookconfigurations -o name | { grep -ciE 'istio|linkerd' || true; } | tr -d ' ')"
kubectl -n starfleet create configmap architecture-report --from-literal=agent-pods="$AP" --from-literal=envoy-pods="$EP" --from-literal=max-containers="$MC" --from-literal=sidecar-webhooks="$SW" --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
