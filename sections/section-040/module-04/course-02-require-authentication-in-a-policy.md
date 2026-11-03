---
draft: true
---
# Require Authentication In A Policy

Authentication is not a separate object. It is a field of a policy rule. A rule says who may talk to whom, and the field says that the pair must also prove its identity.

## The rule

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: scout-require-auth
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: scout
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      authentication:
        mode: required
      toPorts:
        - ports:
            - port: "9898"
              protocol: TCP
```

The field `authentication.mode: required` is part of the ingress rule, next to `fromEndpoints`. The only mode in the API is `required`: the rule applies only when authentication has happened. The rule may also be in an egress block.

## What happens

1. `shuttle` sends the first packet to `scout`.
2. The datapath finds the rule and sees that authentication is needed, and no valid entry exists yet. It drops the packet and tells the agent.
3. The Cilium agent asks SPIRE for the identity documents of both workloads and does a handshake with the agent on the other node. Both sides check the other's document.
4. On success the agent stores an entry for the pair of identities.
5. The next packets match the entry and are allowed.

So the first request can be slow or need a retry, and later ones are fast. The entry is renewed before the SVID expires.

## Try it

<!-- astrona:playground:renew -->

```sh
cat > /tmp/scout-auth.yaml <<'YAML'
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: scout-require-auth
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: scout
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      authentication:
        mode: required
      toPorts:
        - ports:
            - port: "9898"
              protocol: TCP
YAML
kubectl apply -f /tmp/scout-auth.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 10 -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc/
```

The request prints `200`. A request from `drifter` prints `000`, because no rule accepts it.

## Common pitfalls

> [!WARNING]
> A rule with authentication still needs the normal selectors. A rule that requires authentication for too wide a set of pods breaks traffic when SPIRE is down. Start with one pair of workloads, as here, and widen later.
