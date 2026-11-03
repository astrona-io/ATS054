#!/usr/bin/env bash
set -uo pipefail
names="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null)"
if [ "$names" = "probe" ]; then echo "PASS: the Deployment probe has only the container probe"; exit 0; fi
echo "FAIL: the Deployment probe has the containers '$names', expected only 'probe'"
exit 1
