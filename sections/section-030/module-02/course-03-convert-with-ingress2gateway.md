---
draft: true
---
# Convert With ingress2gateway

Translating by hand works for a few objects. For many Ingresses, a conversion tool does the first pass. The Kubernetes SIG project `ingress2gateway` reads Ingress objects and prints Gateway API objects. This part uses it and shows why you must review what it prints.

## What it does

The tool reads Ingress resources, either from a cluster or from files, and prints a Gateway and HTTPRoutes. It supports several Ingress controllers through providers, and each provider knows the annotations of one controller. The list of providers and their coverage changes between versions, so run the help of your version and check whether yours is listed.

## Run it on a file

If the tool is installed, convert the file from the first part:

<!-- astrona:playground:renew -->

```sh
ingress2gateway print --input-file ingress.yaml --providers ingress-nginx
```

The command and the flags depend on the version, so check `ingress2gateway print --help`. The output has a `Gateway` and an `HTTPRoute` that are close to the ones you wrote by hand. If the tool is not installed, read the translation table from the first part and write the objects yourself: that is also the review you would do on the output.

## Review the output

Treat the output as a draft:

- **Class name.** The tool may leave a placeholder for the GatewayClass. Set it to `cilium`.
- **Listeners.** Check the ports, the protocol and the host names.
- **Annotations.** The tool prints a warning for each annotation it could not convert. Read every warning.
- **Namespaces.** Check which namespace the Gateway lands in and what `allowedRoutes` allows.
- **TLS.** Check that the `certificateRefs` point at the right Secret.

## Validate by applying

Apply the objects to the cluster that runs both controllers, and read the status:

```sh
kubectl apply -f gateway.yaml
kubectl -n starfleet get gateway,httproute
```

`PROGRAMMED` must be `True` for the Gateway and the route must be `Accepted`. A conversion that fails the status check is not finished.

## Common pitfalls

> [!WARNING]
> A tool that converts without a warning has not proven the result correct. Compare the behaviour with a request: send the same requests to the Ingress address and the Gateway address and compare the answers. Tool options change between versions, so read the help of the version you install.
