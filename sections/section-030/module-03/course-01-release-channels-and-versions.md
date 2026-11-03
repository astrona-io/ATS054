---
draft: true
---
# Release Channels And Versions

The Gateway API is delivered as CustomResourceDefinitions (CRDs) that you install yourself. Kubernetes does not include them. What you install decides which kinds and fields your cluster accepts, so this is the first thing to check.

## Two channels

- The **standard** channel has the kinds and fields that are stable (GA) or beta and kept compatible: `GatewayClass`, `Gateway`, `HTTPRoute`, `GRPCRoute` and `ReferenceGrant`.
- The **experimental** channel has everything in the standard channel plus kinds and fields that can still change, such as `TLSRoute`, `TCPRoute` and `UDPRoute` in the versions that carry them.

You choose the channel by the install manifest: `standard-install.yaml` or `experimental-install.yaml` of a release. Cilium needs the standard CRDs, and some features, such as TLS passthrough through a `TLSRoute`, need the experimental ones. Check the Cilium documentation for the list of CRDs of your Cilium version.

## Read what is installed

Every CRD of an official release carries its channel and its bundle version as annotations:

<!-- astrona:playground:renew -->

```sh
kubectl get crd gateways.gateway.networking.k8s.io -o jsonpath='{.metadata.annotations}'; echo
kubectl get crd | grep gateway.networking.k8s.io
kubectl api-resources --api-group=gateway.networking.k8s.io
```

The first command prints the annotations `gateway.networking.k8s.io/channel` and `gateway.networking.k8s.io/bundle-version`. The second lists the CRDs, and the third lists the kinds with their short names and whether they are namespaced. In the playground the channel is `experimental`.

## API versions

Each kind has one or more API versions, such as `v1` and `v1beta1`. Use the highest stable version your cluster serves. A manifest with an old version may still work for a time, but it is a sign that you should update the manifest.

```sh
kubectl get crd httproutes.gateway.networking.k8s.io -o jsonpath='{range .spec.versions[*]}{.name} served={.served} storage={.storage}{"\n"}{end}'
```

The output lists the versions, which ones the API server serves and which one it stores.

## Why this matters for a route

A route that uses a kind or a field from the experimental channel is rejected or pruned on a cluster with the standard CRDs. Pruned fields are silent: the API server accepts the object and drops the unknown field. Always read back what you applied.

## Common pitfalls

> [!WARNING]
> Do not mix CRDs of two channels or two releases by applying them one over another without reading the notes of the release. Installing the experimental CRDs on a cluster that has the standard ones is a normal upgrade, but the reverse removes kinds and can delete objects. Keep the CRD manifests in version control.
