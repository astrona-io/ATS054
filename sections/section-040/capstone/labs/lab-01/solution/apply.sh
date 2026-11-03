#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
chart_path="$(mktemp)"
trap 'rm -f "$chart_path"' EXIT
curl --fail --silent --show-error --location --max-time 120 https://helm.cilium.io/cilium-1.20.2.tgz -o "$chart_path"
helm upgrade cilium "$chart_path" -n kube-system --reuse-values --set encryption.nodeEncryption=true --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
sleep 15
echo "[solution] Applied."
