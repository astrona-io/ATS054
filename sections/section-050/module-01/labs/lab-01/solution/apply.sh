#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl -n starfleet patch deployment probe --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/1"}]'
kubectl -n starfleet rollout status deployment/probe --timeout=180s
sleep 5
echo "[solution] Applied."
