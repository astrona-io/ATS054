---
estimated_duration: 25m
---

# Lab: Rotate The IPsec Key Secret

Graded lab for the module on operating IPsec encryption. **UNTESTED:** it was checked with `astrona validate` and `bash -n` only and has not been run. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-054-lab-040-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-secret-has-one-key-line.sh` | The Secret has the key keys with one key line of four fields |
| `validate-spi-is-two.sh` | The SPI of the key is 2 |
| `validate-algorithm-and-size-valid.sh` | The algorithm is rfc4106(gcm(aes)), the key is 40 hex characters and the ICV size is 128 |
| `validate-key-changed.sh` | The key differs from the old key |
