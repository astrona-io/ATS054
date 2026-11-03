---
draft: true
---
# Replace Annotations With Fields And Filters

The Ingress API is small, so controllers added the missing features as annotations. Annotations differ between controllers and are not checked by the API server. The Gateway API has fields and filters for the common ones. This part replaces the annotations you are most likely to have.

## The common replacements

| Annotation purpose | Gateway API |
| --- | --- |
| Redirect HTTP to HTTPS | A `RequestRedirect` filter with `scheme: https` on a route attached to the HTTP listener |
| Rewrite a path | A `URLRewrite` filter with `ReplacePrefixMatch` or `ReplaceFullPath` |
| Add or remove headers | `RequestHeaderModifier` and `ResponseHeaderModifier` filters |
| Canary by weight | `weight` on `backendRefs` |
| Canary by header | A rule with a `headers` match |
| TLS secret | `certificateRefs` of a listener, with a `ReferenceGrant` across namespaces |
| Load balancer mode and Service type | Controller settings or the `infrastructure` and parameters of the Gateway; check the Cilium documentation |

## Example: HTTP to HTTPS redirect

On Cilium Ingress, the annotation `ingress.cilium.io/force-ssl-redirect: "true"` redirects HTTP clients to HTTPS. In the Gateway API you attach a second route to the HTTP listener that does nothing but redirect:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: fleet-redirect
  namespace: starfleet
spec:
  parentRefs:
    - name: fleet
      sectionName: web
  hostnames:
    - fleet.example.com
  rules:
    - filters:
        - type: RequestRedirect
          requestRedirect:
            scheme: https
            statusCode: 301
```

The route holds the redirect and no backend, as the filters module explained. It needs a listener named `web` on the Gateway, and the real route attaches to an HTTPS listener.

<!-- astrona:playground:renew -->

```sh
kubectl apply -f httproute-redirect.yaml
kubectl -n starfleet get httproute fleet-redirect -o jsonpath='{.status.parents[*].conditions[*].type}={.status.parents[*].conditions[*].status}'
```

The route is accepted if the listener `web` exists. This is the check you do for every converted object: read its status.

## Annotations with no equivalent

Some annotations have no field. Timeouts, rate limits and authentication differ between controllers. Some are available as Gateway API extensions or as controller-specific policy objects. Write them in a list during the migration, and for each one decide: use a Gateway API field, use a Cilium extension, solve it in the application, or accept that the feature is gone.

## Common pitfalls

> [!WARNING]
> Do not copy an annotation into a Gateway or a route and expect it to work: the Gateway controller ignores annotations that it does not know. A feature that silently disappears in a migration is worse than a feature that fails to convert, so keep the list of annotations and tick each one off.
