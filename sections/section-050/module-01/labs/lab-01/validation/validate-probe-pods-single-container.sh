#!/usr/bin/env bash
set -uo pipefail
lines="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{range .items[*]}{.spec.containers[*].name}{"\n"}{end}' 2>/dev/null)"
[ -n "$lines" ] || { echo "FAIL: no probe pods found"; exit 1; }
bad="$(printf '%s\n' "$lines" | grep -vcx 'probe')"
if [ "$bad" -ne 0 ]; then echo "FAIL: $bad probe pod(s) still have more than the container probe"; exit 1; fi
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
want="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null)"
if [ -n "$ready" ] && [ "$ready" = "$want" ]; then echo "PASS: all probe pods have one container and are Ready"; exit 0; fi
echo "FAIL: ready replicas '$ready', expected '$want'"
exit 1
