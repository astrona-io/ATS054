---
estimated_duration: 25m
---

# Lab: Inventory The Gateway API Of A Cluster

Graded lab for the module on Gateway API channels, conformance and extensions. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-054-lab-030-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-channel-recorded.sh` | The key channel matches the channel of the installed CRDs |
| `validate-bundle-version-recorded.sh` | The key bundle-version matches the installed bundle version |
| `validate-class-accepted-recorded.sh` | The key class-accepted matches the Accepted condition of the GatewayClass cilium |
| `validate-tlsroute-recorded.sh` | The key has-tlsroute is yes when the CRD tlsroutes exists and no when it does not |
