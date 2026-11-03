---
estimated_duration: 30m
---

# Capstone: Migrate Two Services From Sidecars To The Node Proxy

Section capstone. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-054-capstone-050
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-no-sidecars-left.sh` | Neither Deployment has the container `mesh-proxy` |
| `validate-scout-rules-enforced.sh` | `scout` accepts GET from `shuttle` only |
| `validate-probe-rules-enforced.sh` | `probe` accepts GET `/get` from `shuttle` only |
| `validate-node-proxy-healthy.sh` | `cilium-envoy` and the pods are ready |
