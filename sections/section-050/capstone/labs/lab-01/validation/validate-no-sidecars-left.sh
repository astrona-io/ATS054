#!/usr/bin/env bash
set -uo pipefail
fail=0
for name in scout probe; do
  names="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null)"
  if [ "$names" != "$name" ]; then echo "FAIL: deployment $name has the containers '$names', expected only '$name'"; fail=1; fi
  lines="$(kubectl -n starfleet get pods -l "app=$name" -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}' 2>/dev/null)"
  bad="$(printf '%s\n' "$lines" | grep -vcx "$name")"
  if [ "$bad" -ne 0 ]; then echo "FAIL: $bad $name pod(s) still have an extra container"; fail=1; fi
done
[ "$fail" -eq 0 ] && echo "PASS: no mesh proxy container is left"
exit "$fail"
