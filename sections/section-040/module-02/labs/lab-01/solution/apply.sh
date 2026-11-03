#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
line="$(kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep '^Encryption')"
IF="$(echo "$line" | sed -n 's/.*, \([^ ]*\) (Pubkey.*/\1/p')"
PORT="$(echo "$line" | sed -n 's/.*Port: \([0-9]*\).*/\1/p')"
PEERS="$(echo "$line" | sed -n 's/.*Peers: \([0-9]*\).*/\1/p')"
NE="$(echo "$line" | sed -n 's/.*NodeEncryption: \([A-Za-z]*\).*/\1/p')"
kubectl -n starfleet create configmap encryption-report --from-literal=interface="$IF" --from-literal=port="$PORT" --from-literal=peers="$PEERS" --from-literal=node-encryption="$NE" --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
