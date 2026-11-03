---
draft: true
---
# Migrate One Namespace At A Time

A namespace is a good unit for a migration: it has an owner, a set of workloads and a clear label. Move one, check it, then move the next.

## The order

1. **Pick a low-risk namespace** with an owner who agrees and a good test.
2. **Add the Cilium policies** for the namespace first, while the sidecars are still there. Both sets apply, and you can compare the flows with Hubble. Start with rules that allow what is allowed today.
3. **Stop new injection**: remove the injection label or annotation from the namespace. Existing pods keep their sidecars.
4. **Restart the workloads** one by one with a rolling update. New pods start without a sidecar.
5. **Check each workload** before the next: ready pods, flows, errors in the application.
6. **Remove the old mesh objects** of the namespace when all workloads are done.

## Commands

```sh
kubectl label namespace outpost sidecar.example.io/inject-
kubectl -n outpost rollout restart deployment relay
kubectl -n outpost rollout status deployment relay
kubectl -n outpost get pods -o custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name
```

The first command removes the label (the minus sign at the end). The restart makes new pods, and the last command shows that they have one container. In the playground the label does not exist, so try the commands on a copy of the idea: add the label, remove it, and restart `drifter`.

<!-- astrona:playground:renew -->

```sh
kubectl label namespace outpost sidecar.example.io/inject=true
kubectl label namespace outpost sidecar.example.io/inject-
kubectl -n outpost rollout restart deployment drifter
```

## Keep both working

While a namespace is half moved, requests between a pod with a sidecar and a pod without one must still work. Check this for every pair before you restart the next workload. If the old mesh enforces mutual TLS strictly, relax it to permissive for the namespace first, or the pods without a sidecar cannot be reached.

## Common pitfalls

> [!WARNING]
> Do not remove the injection label of all namespaces at once, and do not restart everything in one step. A mistake is then everywhere. Move one namespace, wait for a full traffic cycle of the application, and only then continue.
