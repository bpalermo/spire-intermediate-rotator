# spire-intermediate-rotator

Container image that rotates a SPIRE `UpstreamAuthority: disk` intermediate CA by
re-signing a short-lived EC intermediate with an **AWS KMS** root key, writing the
result to a Kubernetes Secret, and restarting the SPIRE server.

Bundles `step` + `step-kms-plugin` (for KMS-backed signing) + `kubectl`.

## Env vars
| Var | Required | Default | Meaning |
|-----|----------|---------|---------|
| `ROOT_KEY_ID` | yes | — | AWS KMS key id of the root CA |
| `AWS_REGION` | yes | — | KMS region |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | yes | — | creds with `kms:Sign` on the root |
| `NAMESPACE` | no | `spire-server` | namespace of the secret + statefulset |
| `SECRET_NAME` | no | `spiffe-upstream-ca` | secret to write (tls.crt/tls.key/bundle.crt) |
| `SPIRE_STATEFULSET` | no | `spire-server` | statefulset to `rollout restart` |
| `INT_TTL` | no | `2160h` | intermediate validity (90d) |
| `INT_SUBJECT` | no | `Palermo Intermediate CA - aether.internal` | subject CN |
| `ROOT_CRT` | no | `/root-ca/root.crt` | path to the mounted root cert (bundle) |

The root cert (public) is mounted from a ConfigMap at `ROOT_CRT`.
