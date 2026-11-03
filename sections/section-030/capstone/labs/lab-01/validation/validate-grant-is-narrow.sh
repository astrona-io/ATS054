#!/usr/bin/env bash
set -uo pipefail
fail=0
rows="$(kubectl -n starfleet get referencegrant -o jsonpath='{range .items[*]}{.spec.from[*].kind}/{.spec.from[*].namespace}/{.spec.to[*].kind}/{.spec.to[*].name}{"\n"}{end}' 2>/dev/null)"
n="$(echo "$rows" | grep -cx 'HTTPRoute/outpost/Service/probe')"
if [ "${n:-0}" -ge 1 ]; then echo "PASS: a narrow ReferenceGrant exists in starfleet"; exit 0; fi
echo "FAIL: no ReferenceGrant in starfleet limits from to HTTPRoute in outpost and to to the Service probe"
exit 1
