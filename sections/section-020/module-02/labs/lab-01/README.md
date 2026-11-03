---
estimated_duration: 25m
---

# Lab: Turn On Layer 7 Load Balancing For A Service

Graded lab for the module on traffic management with the Cilium Envoy proxy. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-054-lab-020-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-l7-lb-enabled.sh` | The Service probe-lb has the annotation service.cilium.io/lb-l7 set to enabled |
| `validate-algorithm-least-request.sh` | The Service uses the least_request algorithm |
| `validate-service-answers.sh` | A request to probe-lb from shuttle returns 200 |
| `validate-selector-kept.sh` | The Service still selects app=probe on port 80 |
