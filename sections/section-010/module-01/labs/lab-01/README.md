---
estimated_duration: 25m
---

# Lab: Fix And Extend A Cilium Gateway Route

Graded lab for the module on Cilium Ingress and Gateway API. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-054-lab-010-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route-accepted.sh` | `Accepted` and `ResolvedRefs` are `True` on the route |
| `validate-default-routes-to-scout.sh` | A request for `fleet.example.com` returns the podinfo reply with status 200 |
| `validate-header-routes-to-probe.sh` | `/uuid` with `x-fleet: probe` returns 200 and without the header does not |
| `validate-gateway-unchanged.sh` | The listener still has `from: Same` and only one HTTPRoute exists |
