#!/usr/bin/env bash
set -uo pipefail
line() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status 2>/dev/null | grep '^Encryption'; }
cm() { kubectl -n starfleet get configmap encryption-report -o "jsonpath={.data.$1}" 2>/dev/null; }
# Check: The key port is the UDP listen port the agent reports
have="$(cm port)"
want="$(line | sed -n 's/.*Port: \([0-9]*\).*/\1/p')"
if [ -n "$want" ] && [ "$have" = "$want" ]; then echo "PASS: port is '$have'"; exit 0; fi
echo "FAIL: port in the ConfigMap is '$have', the agent says '$want'"
exit 1
