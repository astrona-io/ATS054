---
estimated_duration: 30m
---

# Capstone: Add Node-To-Node Encryption To WireGuard

Section capstone. **UNTESTED:** checked with `astrona validate` and `bash -n` only. The checks need a host kernel with WireGuard support and `helm` on the machine that runs them. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-054-capstone-040
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-node-encryption-enabled.sh` | `encrypt-node` is `true` in `cilium-config` |
| `validate-wireguard-still-active.sh` | Every agent reports WireGuard |
| `validate-helm-values-keep-it.sh` | The Helm release holds `nodeEncryption` and `type: wireguard` |
| `validate-pod-traffic-works.sh` | Pods still reach each other |
