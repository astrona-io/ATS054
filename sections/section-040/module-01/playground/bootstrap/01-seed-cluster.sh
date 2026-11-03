#!/usr/bin/env bash
# Starting state: kind cluster, kube-proxy removed, Cilium installed with the
# values this environment needs, then the Starfleet workloads.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-054-playground-040-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Cilium replaces kube-proxy, so remove it before Cilium starts.
kubectl -n kube-system delete daemonset kube-proxy --ignore-not-found
kubectl -n kube-system delete configmap kube-proxy --ignore-not-found

chart_path="$(mktemp)"
trap 'rm -f "$chart_path"' EXIT
curl --fail --silent --show-error --location --max-time 120 https://helm.cilium.io/cilium-1.20.2.tgz -o "$chart_path"
echo "b2afd87b7f75f875f92a14559f14f59b7babbb479d968e3fd625a20bf30ec20e  $chart_path" | shasum -a 256 -c -

helm upgrade --install cilium "$chart_path" -n kube-system \
  --set ipam.mode=kubernetes \
  --set operator.replicas=1 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=astro-ats-054-playground-040-01-control-plane \
  --set k8sServicePort=6443 \
  --set encryption.enabled=true \
  --set encryption.type=wireguard \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set authentication.enabled=true \
  --set authentication.mutual.spire.enabled=true \
  --set authentication.mutual.spire.install.enabled=true \
  --set authentication.mutual.spire.install.server.dataStorage.enabled=false \
  --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl wait --for=condition=Ready nodes --all --timeout=180s

kubectl apply -f "$DIR/manifests/starfleet.yaml"
for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[env] Ready."
