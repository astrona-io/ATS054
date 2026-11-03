---
estimated_duration: 25m
---

# Lab: Repair A Broken Gateway Route

Graded lab for the module on troubleshooting Cilium Ingress and Gateway API. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-05/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-05/labs/lab-01
astrona destroy ats-054-lab-010-05
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route-accepted.sh` | The HTTPRoute fleet is Accepted |
| `validate-refs-resolved.sh` | The backend reference of the route resolves |
| `validate-fleet-reaches-scout.sh` | A request for fleet.example.com reaches scout |
| `validate-gateway-kept.sh` | The Gateway listener is unchanged |
