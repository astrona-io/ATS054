---
estimated_duration: 25m
---

# Lab: Migrate An Ingress To A Gateway And An HTTPRoute

Graded lab for the module on migrating from Ingress to Gateway API. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-054-lab-030-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route-accepted.sh` | An HTTPRoute in starfleet is accepted by a Gateway |
| `validate-gateway-default-scout.sh` | A request for / through the Gateway reaches scout |
| `validate-gateway-probe-prefix.sh` | A request for /probe through the Gateway is served by probe and not by scout |
| `validate-ingress-removed.sh` | The old Ingress fleet is deleted |
