#!/usr/bin/env bash
set -uo pipefail
line() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status 2>/dev/null | grep '^Encryption'; }
cm() { kubectl -n starfleet get configmap encryption-report -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key node-encryption is Enabled or Disabled as the agent reports
have="$(cm node-encryption)"
want="$(line | sed -n 's/.*NodeEncryption: \([A-Za-z]*\).*/\1/p')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: node-encryption is '$have'"; exit 0; fi
echo "FAIL: node-encryption in the ConfigMap is '$have', the agent says '$want'"
exit 1
