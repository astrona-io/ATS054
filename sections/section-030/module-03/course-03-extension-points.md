---
draft: true
---
# Extension Points

The Gateway API cannot define everything every implementation offers. It defines places where an implementation may plug in its own behaviour. This part names the three main places and shows how to use them without breaking portability more than you must.

## ExtensionRef filters

A route filter of type `ExtensionRef` points at an object that the implementation defines. The route says "apply the behaviour described there". It is the place for things like rate limits or custom authentication that are not part of the standard filters:

```yaml
      filters:
        - type: ExtensionRef
          extensionRef:
            group: example.io
            kind: RateLimit
            name: fleet-limit
```

If the controller does not know the kind, the route is not accepted, and the status says why. The standard fields of the route stay portable; only the extension object is tied to one controller.

## parametersRef on a GatewayClass

A GatewayClass can have a `parametersRef` that points at an object with settings for the whole class. The type of that object is defined by the implementation. Read whether the Cilium class uses one:

<!-- astrona:playground:renew -->

```sh
kubectl get gatewayclass cilium -o jsonpath='{.spec.parametersRef}'; echo
```

An empty line means no parameters are set. The Gateway API also lets a Gateway describe its infrastructure (labels and annotations for the objects the controller creates for it) in `spec.infrastructure`, which is the portable place for things such as Service annotations.

## Policy attachment

A **policy** is an object that attaches to a Gateway, a route or a Service with a `targetRefs` field and changes how it behaves. The Gateway API defines the pattern, and a few standard policies, such as `BackendTLSPolicy` for the TLS between the Gateway and a backend, have been proposed or added in some versions. Implementations also define their own policies. Check whether your Cilium version supports a policy before you write one:

```sh
kubectl api-resources --api-group=gateway.networking.k8s.io | grep -i policy
kubectl api-resources --api-group=cilium.io | head -20
```

The first command lists policy kinds of the Gateway API CRDs that are installed. The second lists the Cilium kinds, some of which, such as `CiliumEnvoyConfig`, are Cilium's own way to reach Envoy.

## Choosing

Prefer standard fields and filters. Use an extension only when no standard field does the job, keep it in a separate, labelled object so that it is easy to find, and write down why. A route with extensions needs a test on any controller you move to.

## Common pitfalls

> [!WARNING]
> An extension object is not checked by the Gateway API schema. A typo in its fields may be accepted by the API server and ignored by the controller, so read the status. Policies attach by `targetRefs`, and a policy that targets the wrong object does nothing and can look as if it works.
