---
estimated_duration: 25m
---

# Lab: Add A Redirect And A Rewrite To An HTTPRoute

Graded lab for the module on HTTPRoute filters and traffic management. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-04/labs/lab-01
astrona destroy ats-054-lab-010-04
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route-accepted.sh` | The HTTPRoute fleet is accepted and its references resolve |
| `validate-old-path-redirects.sh` | A request for /old/page gets a 301 redirect to probe.example.com |
| `validate-probe-prefix-rewritten.sh` | A request for /probe/uuid reaches probe with the path /uuid |
| `validate-default-still-scout.sh` | Other requests still reach scout and the Gateway is unchanged |
