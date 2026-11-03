#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/manifests/solution-gateway.yaml"
kubectl label namespace starfleet access=gateway --overwrite
sleep 15
echo "[solution] Applied."
