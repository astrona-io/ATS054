---
estimated_duration: 25m
---

# Lab: Restrict The Egress Of A Pod With A CiliumNetworkPolicy

Graded lab for the module on security use cases with Cilium. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-054-lab-020-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-policy-selects-shuttle.sh` | A CiliumNetworkPolicy in starfleet selects the pods with app=shuttle |
| `validate-scout-reachable.sh` | shuttle can still reach scout by name |
| `validate-probe-blocked.sh` | shuttle can no longer reach probe |
| `validate-drifter-unaffected.sh` | drifter in outpost still reaches probe |
