---
estimated_duration: 25m
---

# Lab: Turn On WireGuard Encryption

Graded lab for the module on encryption in transit. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The WireGuard checks need a host kernel with WireGuard support. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-054-lab-040-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-wireguard-configured.sh` | `enable-wireguard` is `true` in `cilium-config` |
| `validate-agents-report-wireguard.sh` | Every agent reports WireGuard in `cilium-dbg status` |
| `validate-pod-traffic-works.sh` | Pods still reach each other |
