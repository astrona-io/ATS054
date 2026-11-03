---
estimated_duration: 25m
---

# Lab: Prove The Cluster Runs Without Sidecars

Graded lab for the module on sidecarless architecture in practice. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-054-lab-050-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-agent-pods-recorded.sh` | The key agent-pods is the number of Cilium agent pods |
| `validate-envoy-pods-recorded.sh` | The key envoy-pods is the number of cilium-envoy pods |
| `validate-max-containers-recorded.sh` | The key max-containers is the largest number of containers in one pod of starfleet and outpost |
| `validate-sidecar-webhooks-recorded.sh` | The key sidecar-webhooks is the number of mutating webhooks whose name has istio or linkerd |
