#!/usr/bin/env bash
set -euo pipefail
: "${ROOT_KEY_ID:?ROOT_KEY_ID required}"; : "${AWS_REGION:?AWS_REGION required}"
NS="${NAMESPACE:-spire-server}"; SECRET="${SECRET_NAME:-spiffe-upstream-ca}"
STS="${SPIRE_STATEFULSET:-spire-server}"; TTL="${INT_TTL:-2160h}"
SUBJECT="${INT_SUBJECT:-Palermo Intermediate CA - aether.internal}"
ROOT_CRT="${ROOT_CRT:-/root-ca/root.crt}"; W="$(mktemp -d)"
echo "[rotate] signing intermediate (TTL=$TTL) via KMS root ${ROOT_KEY_ID}"
step certificate create "$SUBJECT" "$W/tls.crt" "$W/tls.key" \
  --profile intermediate-ca --ca "$ROOT_CRT" \
  --ca-key "awskms:key-id=${ROOT_KEY_ID}" --kms "awskms:region=${AWS_REGION}" \
  --kty EC --curve P-256 --not-after "$TTL" --no-password --insecure --force
echo "[rotate] applying $NS/$SECRET and restarting statefulset/$STS"
kubectl create secret generic "$SECRET" -n "$NS" \
  --from-file=tls.crt="$W/tls.crt" --from-file=tls.key="$W/tls.key" --from-file=bundle.crt="$ROOT_CRT" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl rollout restart "statefulset/$STS" -n "$NS"
echo "[rotate] done"
