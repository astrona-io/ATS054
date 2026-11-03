---
estimated_duration: 25m
---

# Lab: Fix An HTTPS Listener On A Cilium Gateway

Graded lab for the module on Gateway listeners, TLS and route types. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-054-lab-010-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-certificate-ref-resolved.sh` | `ResolvedRefs` is `True` on the listener |
| `validate-route-accepted.sh` | The route is accepted |
| `validate-https-reaches-scout.sh` | An HTTPS request returns the podinfo reply with status 200 |
| `validate-listener-kept.sh` | Port, host name and TLS mode are unchanged |
