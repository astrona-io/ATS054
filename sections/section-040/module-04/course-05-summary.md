---
draft: true
---
# Summary

You used mutual authentication with SPIRE and read what it proves.

## Key points

- SPIRE has a server, an agent on each node and registration entries from the operator.
- A workload identity is a SPIFFE ID, proved by a short-lived SVID.
- `authentication.mode: required` in a rule makes the pair prove its identity first.
- The first packet may be dropped while the handshake runs; the agent keeps an entry afterwards.
- Authentication is not encryption and not authorization.

## What to practise

Apply the rule for `scout`, read the authentication table, and send a request from `drifter` to see it denied.

<!-- astrona:playground:destroy -->
