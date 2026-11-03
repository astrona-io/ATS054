#!/usr/bin/env bash
set -uo pipefail
code_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' "$@" 2>/dev/null; }
ann() { kubectl -n starfleet get service probe-lb -o "jsonpath={.metadata.annotations.$1}" 2>/dev/null; }
# Check: The Service uses the least_request algorithm
v="$(ann 'service\.cilium\.io/lb-l7-algorithm')"
if [ "$v" = "least_request" ]; then echo "PASS: the algorithm is least_request"; exit 0; fi
echo "FAIL: the annotation service.cilium.io/lb-l7-algorithm is '$v', expected 'least_request'"
exit 1
