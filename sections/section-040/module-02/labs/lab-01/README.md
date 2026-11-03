---
estimated_duration: 25m
---

# Lab: Record The WireGuard Settings Of A Cluster

Graded lab for the module on operating WireGuard encryption. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-054-lab-040-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-interface-recorded.sh` | The key interface is the WireGuard device the agent reports |
| `validate-port-recorded.sh` | The key port is the UDP listen port the agent reports |
| `validate-peers-recorded.sh` | The key peers is the number of WireGuard peers the agent reports |
| `validate-node-encryption-recorded.sh` | The key node-encryption is Enabled or Disabled as the agent reports |
