#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="${SCRIPT_DIR}/../overlays/cluster3/sealedsecret-env.yaml"

read_secret() {
  local var_name="$1"
  local prompt="$2"
  if [[ -n "${!var_name:-}" ]]; then
    echo "${!var_name}"
  else
    read -rsp "${prompt}: " value
    echo >&2
    echo "$value"
  fi
}

echo "Generating waha SealedSecret for cluster3..." >&2

WAHA_API_KEY=$(read_secret WAHA_API_KEY "WAHA_API_KEY")
WAHA_DASHBOARD_USERNAME=$(read_secret WAHA_DASHBOARD_USERNAME "WAHA_DASHBOARD_USERNAME")
WAHA_DASHBOARD_PASSWORD=$(read_secret WAHA_DASHBOARD_PASSWORD "WAHA_DASHBOARD_PASSWORD")
WHATSAPP_SWAGGER_USERNAME=$(read_secret WHATSAPP_SWAGGER_USERNAME "WHATSAPP_SWAGGER_USERNAME")
WHATSAPP_SWAGGER_PASSWORD=$(read_secret WHATSAPP_SWAGGER_PASSWORD "WHATSAPP_SWAGGER_PASSWORD")

kubectl create secret generic waha-env \
  --from-literal=WAHA_API_KEY="$WAHA_API_KEY" \
  --from-literal=WAHA_DASHBOARD_USERNAME="$WAHA_DASHBOARD_USERNAME" \
  --from-literal=WAHA_DASHBOARD_PASSWORD="$WAHA_DASHBOARD_PASSWORD" \
  --from-literal=WHATSAPP_SWAGGER_USERNAME="$WHATSAPP_SWAGGER_USERNAME" \
  --from-literal=WHATSAPP_SWAGGER_PASSWORD="$WHATSAPP_SWAGGER_PASSWORD" \
  --dry-run=client -o yaml \
  | kubeseal \
      --scope cluster-wide \
      --format yaml \
      > "$OUTPUT"

echo "Generated: $OUTPUT" >&2
