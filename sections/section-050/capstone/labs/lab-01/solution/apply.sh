#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for name in scout probe; do
  kubectl -n starfleet patch deployment "$name" --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/1"}]'
done
kubectl apply -f "$DIR/manifests/capstone-solution.yaml"
for name in scout probe; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
sleep 10
echo "[solution] Applied."
