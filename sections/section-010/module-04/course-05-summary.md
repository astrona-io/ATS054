---
draft: true
---
# Summary

You used the filters and matches of an `HTTPRoute` to manage traffic in the Cilium Gateway.

## Key points

- A rule has matches, filters and weighted backends. Path ranks first, then method, headers and query parameters.
- `RequestHeaderModifier` and `ResponseHeaderModifier` set, add and remove headers.
- `RequestRedirect` answers with `301` or `302` and cannot share a rule with `backendRefs`.
- `URLRewrite` changes the path prefix, the full path or the host that the backend sees.
- `RequestMirror` copies traffic to a second backend and drops its answer.
- `weight` splits traffic by share, and weight `0` is the rollback.

## What to practise

Write a route with a redirect and a prefix rewrite, then shift a canary from 10 to 0 and back. Check each change with a request, not with the YAML.

<!-- astrona:playground:destroy -->
