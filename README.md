# spire-intermediate-rotator

Minimal **distroless** toolbox image for rotating a SPIRE `UpstreamAuthority: disk`
intermediate CA: re-sign a short-lived EC intermediate with an **AWS KMS** root key,
write it to a Kubernetes Secret, and restart the SPIRE server.

Bundles `step` + `step-kms-plugin` (KMS-backed signing) + `kubectl`, on
`gcr.io/distroless/base-debian12:nonroot` (no shell). The rotation is driven by the
Kubernetes CronJob as single-command containers (sign → recreate secret → rollout
restart), e.g. in `bpalermo/k8s-talos-main` under `clusters/talos-main/spire-int-rotator`.

## Contents
| Tool | Purpose |
|------|---------|
| `step` + `step-kms-plugin` | `step certificate create --ca-key awskms:key-id=… --kms awskms:region=…` |
| `kubectl` | recreate the `spiffe-upstream-ca` secret + `rollout restart` the SPIRE StatefulSet |

Pinned: step 0.30.6, step-kms-plugin 0.17.0, kubectl 1.36.1 (override via build args).

Published to `ghcr.io/bpalermo/spire-intermediate-rotator` (and Docker Hub when CI
secrets are configured).
