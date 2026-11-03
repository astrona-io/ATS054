---
estimated_duration: 25m
---

# Lab: Delegate Gateway Access By Namespace Label

Graded lab for the module on the Gateway API compared with Ingress. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-054-lab-030-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-starfleet-route-accepted.sh` | `Accepted=True` on the route in `starfleet` |
| `validate-scout-reachable-through-gateway.sh` | `scout.example.com` returns the scout reply through the Gateway |
| `validate-outpost-route-not-accepted.sh` | The route in `outpost` is not accepted |
| `validate-selector-in-use.sh` | The listener uses `Selector` on `access=gateway` and `outpost` is not labelled |
