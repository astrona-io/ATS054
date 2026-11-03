---
estimated_duration: 30m
---

# Capstone: Share A Backend Across Namespaces With A Gateway

Section capstone. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-054-capstone-030
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route-accepted-and-resolved.sh` | `Accepted` and `ResolvedRefs` are `True` |
| `validate-probe-reachable-through-gateway.sh` | `probe.example.com` returns 200 for `/uuid` |
| `validate-grant-is-narrow.sh` | A ReferenceGrant in `starfleet` limits `from` and `to` |
| `validate-gateway-unchanged.sh` | The Gateway selector is unchanged |
