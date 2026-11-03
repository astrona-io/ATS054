---
draft: true
---
# Upgrade And Compatibility

The Gateway API and Cilium both release often. An upgrade of one can break the other. This part gives a plan for upgrading the CRDs and the controller without losing routes.

## What must match

Each Cilium release is built and tested against a Gateway API version. The Cilium documentation lists the version and the CRDs that must be installed. Two rules follow:

1. Install the CRDs **before** you install or upgrade Cilium, and restart the Cilium operator if you changed them afterwards.
2. Do not run CRDs that are much newer than the version your Cilium release supports. New fields would be accepted by the API server and ignored by the controller.

## A safe upgrade order

1. **Read the release notes** of the Gateway API version for removed or changed fields. Look for fields your manifests use.
2. **Export your objects.** Keep a copy of your Gateways and routes:

   ```sh
   kubectl get gateway,httproute,grpcroute,referencegrant -A -o yaml > gateway-backup.yaml
   ```

3. **Test the upgrade in a cluster that is a copy** of production, not in production.
4. **Apply the new CRDs.** Applying a CRD manifest from a newer release of the same channel is the normal path.
5. **Upgrade Cilium** when its release matches the CRDs, then restart the operator if needed.
6. **Read the status** of every Gateway and route. `Accepted` and `Programmed` must still be `True`.

## Check after the upgrade

<!-- astrona:playground:renew -->

```sh
kubectl get gatewayclass
kubectl get gateway,httproute -A
kubectl get gateway -A -o jsonpath='{range .items[*]}{.metadata.name} {.status.conditions[?(@.type=="Programmed")].status}{"\n"}{end}'
```

The class shows `ACCEPTED` as `True`. Each Gateway line ends with `True`. A `False` or an empty value means the controller has not accepted or programmed it, and the conditions say why.

## Stored versions

When the CRDs move to a new storage version, objects keep the old stored version until they are written again. The release notes say when a migration step is needed. Do not remove an old API version from a CRD while objects are still stored in it.

## Common pitfalls

> [!WARNING]
> Do not delete CRDs to "start clean": deleting a CRD deletes every object of that kind, including your Gateways and routes. Pin the CRD manifest by version and checksum in your tooling, as the playground does with the release URL. An upgrade that you tested only with the HTTP listener has not been tested for TLS.
