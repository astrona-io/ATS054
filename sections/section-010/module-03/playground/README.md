# Gateway Listeners, TLS And Route Types: Playground

- **Slug:** ats-054-playground-010-03
- **Type:** Astrona playground, clean environment, no task, no grading
- **Status:** UNTESTED. The environment was checked with `astrona validate` only.

A kind cluster (one control-plane node, one worker) with Cilium installed with kube-proxy replacement, the Cilium Ingress controller (dedicated mode) and the Cilium Gateway API controller. The Gateway API CRDs are installed before Cilium. The Starfleet workloads `scout`, `probe` and `shuttle` run in `starfleet`, and `drifter` runs in `outpost`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-010/module-03/playground
astrona destroy ats-054-playground-010-03
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/01-seed-cluster.sh` | Removes kube-proxy, installs the Gateway API CRDs and Cilium, applies the workloads |
| `manifests/starfleet.yaml` | Namespaces and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and practice ideas |
