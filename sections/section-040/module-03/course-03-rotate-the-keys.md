---
draft: true
---
# Rotate The Keys

A key that never changes is a risk: if it leaks, all past and future traffic is open. Rotate keys on a schedule and after any suspicion. The design of the Secret makes this possible without a stop.

## The idea

The agents keep the key with the **current SPI** and also accept the one before it. When you write a new line with the **next SPI**, each agent adds the new key, starts to send with it and keeps the old one for packets that are still in flight. After a while the old key is not used.

## The order

1. Read the current line and note the SPI.
2. Make a new random key.
3. Write a new line with the SPI raised by one. The SPI is a number from 1 to 15 and wraps after 15.
4. Replace the Secret with only the new line.
5. Wait for the agents to pick it up. They watch the file at an interval, and the chart has a value for it.
6. Read the status on every agent and test traffic.

```sh
kubectl -n kube-system get secret cilium-ipsec-keys -o jsonpath='{.data.keys}' | base64 -d; echo
```

## Check

<!-- astrona:playground:renew -->

```sh
agent cilium-dbg encrypt status
```

On a cluster with IPsec this output lists the keys in use, the number of the highest sequence, and counters of errors. After a rotation, the SPI of the key in use must match the new one on every node. A node that still shows the old SPI has not picked up the Secret.

## Rules for a safe rotation

- Change the SPI every time. The same SPI with a new key is not picked up as a rotation.
- Rotate one cluster at a time.
- Do not write two lines unless the documentation of your version describes the transition.
- Do it when you can watch the error counters.

## Common pitfalls

> [!WARNING]
> Do not reuse a key from an earlier rotation. Do not apply a Secret with an SPI that is lower than the current one. Packets in flight with the old key may be dropped for a moment, so watch the counters, and do not rotate during a change freeze.
