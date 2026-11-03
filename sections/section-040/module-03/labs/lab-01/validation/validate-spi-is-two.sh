#!/usr/bin/env bash
set -uo pipefail
keys() { kubectl -n kube-system get secret cilium-ipsec-keys -o jsonpath='{.data.keys}' 2>/dev/null | base64 -d 2>/dev/null; }
# Check: The SPI of the key is 2
spi="$(keys | awk 'NF>0{print $1; exit}' | tr -d '+')"
if [ "$spi" = "2" ]; then echo "PASS: SPI is 2"; exit 0; fi
echo "FAIL: SPI is '$spi', expected 2"
exit 1
