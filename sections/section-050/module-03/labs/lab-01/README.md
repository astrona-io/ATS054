---
estimated_duration: 25m
---

# Lab: Inventory A Cluster Before A Sidecar Migration

Graded lab for the module on choosing and migrating a mesh architecture. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-03/labs/lab-01
astrona destroy ats-054-lab-050-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-injected-namespaces-recorded.sh` | The key injected-namespaces lists the namespaces with the injection label |
| `validate-sidecar-pods-recorded.sh` | The key sidecar-pods counts the pods that have a container named proxy |
| `validate-l7-policies-recorded.sh` | The key l7-policies counts the CiliumNetworkPolicy objects with an HTTP rule |
| `validate-envoy-ready-recorded.sh` | The key envoy-ready is yes when every cilium-envoy pod is ready |
