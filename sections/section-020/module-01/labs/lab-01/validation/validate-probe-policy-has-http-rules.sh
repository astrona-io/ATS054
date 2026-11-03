#!/usr/bin/env bash
set -uo pipefail
count="$(kubectl -n starfleet get ciliumnetworkpolicy -o yaml 2>/dev/null | grep -c 'http:')"
sel="$(kubectl -n starfleet get ciliumnetworkpolicy -o yaml 2>/dev/null | grep -c 'app: probe')"
if [ "${count:-0}" -ge 1 ] && [ "${sel:-0}" -ge 1 ]; then echo "PASS: a CiliumNetworkPolicy with HTTP rules selects probe"; exit 0; fi
echo "FAIL: no CiliumNetworkPolicy in starfleet selects app=probe with HTTP rules"
exit 1
