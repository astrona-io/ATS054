#!/usr/bin/env bash
set -uo pipefail
fail=0
names="$(kubectl -n starfleet get ciliumnetworkpolicy -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)"
for n in scout-access probe-access; do
  echo " $names " | grep -q " $n " || { echo "FAIL: policy $n is missing"; fail=1; continue; }
  kubectl -n starfleet get ciliumnetworkpolicy "$n" -o yaml 2>/dev/null | grep -q 'http:' || { echo "FAIL: policy $n has no HTTP rules"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: both policies exist and keep their HTTP rules"
exit "$fail"
