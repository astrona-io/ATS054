---
estimated_duration: 25m
---

# Lab: Make HTTP Requests Visible To Hubble

Graded lab for the module on observability with Hubble and metrics. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-04/labs/lab-01
astrona destroy ats-054-lab-020-04
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-policy-has-http-rules.sh` | A policy for probe has HTTP rules for /get and /status |
| `validate-get-allowed.sh` | GET /get from shuttle returns 200 |
| `validate-status-allowed.sh` | GET /status/204 from shuttle returns 204 |
| `validate-uuid-denied.sh` | GET /uuid is denied with 403 |
