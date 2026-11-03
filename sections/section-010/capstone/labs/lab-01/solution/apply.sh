#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl -n starfleet patch ingress scout --type merge -p '{"spec":{"ingressClassName":"cilium"}}'
kubectl label namespace starfleet access=gateway --overwrite
sleep 15
echo "[solution] Applied."
