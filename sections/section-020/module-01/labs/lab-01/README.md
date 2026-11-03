---
estimated_duration: 25m
---

# Lab: Apply Layer 7 Access Control With CiliumNetworkPolicy

Graded lab for the module on service mesh use cases. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-054-lab-020-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-policy-has-http-rules.sh` | A policy with HTTP rules selects `app=probe` |
| `validate-shuttle-get-allowed.sh` | `GET /get` from `shuttle` returns 200 |
| `validate-other-requests-denied.sh` | `GET /uuid` and `POST /post` return 403 |
| `validate-drifter-blocked.sh` | `drifter` gets no reply from `probe` and 200 from `scout` |
