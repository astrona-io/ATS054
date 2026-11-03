---
estimated_duration: 30m
---

# Capstone: Repair Layer 7 Policies Without A Sidecar

Section capstone. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-054-capstone-020
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-get-allowed-for-both.sh` | `GET /` from `shuttle` and `drifter` returns 200 |
| `validate-scout-post-denied.sh` | `POST` to `scout` returns 403 |
| `validate-probe-shuttle-only.sh` | `probe` returns 200 for `GET /get` from `shuttle`, 403 for `/uuid`, no reply for `drifter` |
| `validate-policies-kept.sh` | Both policies exist and keep HTTP rules |
