#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl label namespace outpost access=gateway --overwrite
kubectl apply -f "$DIR/manifests/capstone-grant.yaml"
sleep 15
echo "[solution] Applied."
