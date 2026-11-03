---
estimated_duration: 30m
---

# Capstone: Publish Two Services With Cilium Ingress And Gateway API

Section capstone. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-054-capstone-010
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ingress-served-by-cilium.sh` | The Ingress has class `cilium` and `scout.example.com` returns the scout reply |
| `validate-route-accepted-by-edge.sh` | The `probe` route has `Accepted=True` |
| `validate-probe-reachable-through-gateway.sh` | `probe.example.com` returns 200 for `/uuid` through the Gateway node port |
| `validate-gateway-and-class-unchanged.sh` | The Gateway selector and the Ingress host are unchanged |
