# Operate IPsec Encryption: Playground

- **Slug:** ats-054-playground-040-03
- **Type:** Astrona playground, clean environment, no task, no grading
- **Status:** UNTESTED. Checked with `astrona validate` only.

A kind cluster (one control-plane node, one worker) with Cilium (kube-proxy replacement, no encryption) and the Starfleet workloads.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-040/module-03/playground
astrona destroy ats-054-playground-040-03
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/01-seed-cluster.sh` | Removes kube-proxy, installs Cilium without encryption, applies the workloads |
| `manifests/starfleet.yaml` | Namespaces and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and practice ideas |
