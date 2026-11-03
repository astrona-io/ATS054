---
estimated_duration: 25m
---

# Lab: Fix TLS On A Cilium Ingress

Graded lab for the module on Cilium Ingress in depth. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-054-lab-010-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-tls-secret-exists.sh` | The Ingress names a TLS Secret that exists |
| `validate-https-reaches-scout.sh` | An HTTPS request for the host returns the podinfo reply with status 200 |
| `validate-http-redirects.sh` | A plain HTTP request gets a redirect status |
| `validate-ingress-rule-kept.sh` | Host, class and backend are unchanged |
