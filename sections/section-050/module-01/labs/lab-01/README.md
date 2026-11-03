---
estimated_duration: 20m
---

# Lab: Remove A Leftover Sidecar Proxy

Graded lab for the module on sidecar and sidecarless architectures. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/module-01/labs/lab-01
astrona destroy ats-054-lab-050-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-legacy-proxy-removed.sh` | The Deployment `probe` has only the container `probe` |
| `validate-probe-pods-single-container.sh` | Every probe pod has one container and is Ready |
| `validate-l7-still-enforced.sh` | GET `/get` is allowed, POST is denied, `drifter` is blocked |
| `validate-node-proxy-on-every-node.sh` | `cilium-envoy` is ready on every node |
