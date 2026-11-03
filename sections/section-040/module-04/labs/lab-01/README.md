---
estimated_duration: 25m
---

# Lab: Require Mutual Authentication For A Service

Graded lab for the module on mutual authentication in practice. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-04/labs/lab-01
astrona destroy ats-054-lab-040-04
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-policy-requires-auth.sh` | A policy for scout requires authentication in an ingress rule |
| `validate-policy-selects-scout-and-shuttle.sh` | The policy selects scout and accepts shuttle |
| `validate-shuttle-reaches-scout.sh` | shuttle reaches scout and gets 200 after the authentication |
| `validate-drifter-is-denied.sh` | drifter in another namespace does not reach scout |
