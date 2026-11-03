# Traffic Management With The Cilium Envoy Proxy: Playground

- **Slug:** ats-054-playground-020-02
- **Type:** Astrona playground, clean environment, no task, no grading
- **Status:** UNTESTED. Checked with `astrona validate` only.

A kind cluster (one control-plane node, one worker) with Cilium (kube-proxy replacement, Envoy DaemonSet, Hubble and Hubble Relay) and the Starfleet workloads. No policy exists.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS054.git -c sections/section-020/module-02/playground
astrona destroy ats-054-playground-020-02
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/01-seed-cluster.sh` | Removes kube-proxy, installs Cilium, applies the workloads |
| `manifests/starfleet.yaml` | Namespaces and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and practice ideas |
