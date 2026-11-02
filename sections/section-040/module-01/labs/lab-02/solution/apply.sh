#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-054-lab-040-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
node_name="astro-ats-054-lab-040-01-02-control-plane"
worker_name="astro-ats-054-lab-040-01-02-worker"
bash "$solution_directory/enable-wireguard.sh"
kubectl -n starfleet delete pod/shuttle --wait=true
kubectl apply -f "$solution_directory/deployment-probe.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
