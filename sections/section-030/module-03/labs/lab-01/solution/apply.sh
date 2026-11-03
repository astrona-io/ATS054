#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
CH=$(kubectl get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations.gateway\.networking\.k8s\.io/channel}')
BV=$(kubectl get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}')
AC=$(kubectl get gatewayclass cilium -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}')
if kubectl get crd tlsroutes.gateway.networking.k8s.io >/dev/null 2>&1; then TR=yes; else TR=no; fi
kubectl -n starfleet create configmap gateway-inventory --from-literal=channel="$CH" --from-literal=bundle-version="$BV" --from-literal=class-accepted="$AC" --from-literal=has-tlsroute="$TR" --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
