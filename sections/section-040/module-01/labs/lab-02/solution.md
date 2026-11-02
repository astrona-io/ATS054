---
draft: true
exam_objectives:
- Encrypting Traffic in Transit with Cilium
---
# Enable Cross Node WireGuard Encryption Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-054-lab-040-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-054-lab-040-01-02" || exit 1
node_name="astro-ats-054-lab-040-01-02-control-plane"
worker_name="astro-ats-054-lab-040-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Upgrade only the private Cilium release with encryption enabled and type wireguard. Schedule the probe on the control-plane node and shuttle on the worker, then check actual agent encryption state. The kind node kernel must support WireGuard; this exercise does not alter the physical host kernel.

Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        ports:
        - containerPort: 8080
        command:
        - python
        - -u
        - /code/app.py
        volumeMounts:
        - name: code
          mountPath: /code
      volumes:
      - name: code
        configMap:
          name: probe-code
      nodeSelector:
        kubernetes.io/hostname: astro-ats-054-lab-040-01-02-control-plane
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
---
apiVersion: v1
kind: Pod
metadata:
  name: shuttle
  namespace: starfleet
spec:
  restartPolicy: Never
  containers:
  - name: reader
    image: docker.io/library/python:3.13-alpine
    command:
    - python
    - -c
    - import time; time.sleep(86400)
  nodeName: astro-ats-054-lab-040-01-02-worker
```

Save this as `enable-wireguard.sh`:

```sh
#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-054-lab-040-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
chart_path="$(mktemp)"
trap 'rm -f "$chart_path"' EXIT
curl --fail --silent --show-error --location --max-time 120 https://helm.cilium.io/cilium-1.20.2.tgz -o "$chart_path"
python3 - "$chart_path" <<'CHECKSUM'
import hashlib,sys
assert hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest() == 'b2afd87b7f75f875f92a14559f14f59b7babbb479d968e3fd625a20bf30ec20e', 'Chart checksum differs'
CHECKSUM
helm upgrade --install cilium "$chart_path" -n kube-system --reuse-values --set encryption.enabled=true --set encryption.type=wireguard --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl wait --for=condition=Ready nodes --all --timeout=180s
```

Apply the scoped correction:

```sh
bash enable-wireguard.sh
kubectl -n starfleet delete pod/shuttle --wait=true
kubectl apply -f deployment-probe.yaml
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n starfleet exec shuttle -- python -c 'import urllib.request; print(urllib.request.urlopen('"'"'http://probe:8080/'"'"',timeout=4).read().decode())'
```

Enable WireGuard and verify agent encryption state and cross-node requests. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-054-lab-040-01-02`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
