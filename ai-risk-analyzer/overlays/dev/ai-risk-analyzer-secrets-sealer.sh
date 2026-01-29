#!/bin/bash
# Script to seal secrets for ai-risk-analyzer
# Usage: ./ai-risk-analyzer-secrets-sealer.sh

set -e

# Check if kubeseal is installed
if ! command -v kubeseal &> /dev/null; then
    echo "Error: kubeseal is not installed"
    echo "Install with: brew install kubeseal (macOS) or download from https://github.com/bitnami-labs/sealed-secrets/releases"
    exit 1
fi

# Read secrets from user
echo "AI Risk Analyzer Secrets Configuration"
echo "========================================"
echo ""
read -p "Enter JOGET_USERNAME (default: admin): " JOGET_USERNAME
JOGET_USERNAME=${JOGET_USERNAME:-admin}

read -sp "Enter JOGET_PASSWORD: " JOGET_PASSWORD
echo ""

read -sp "Enter OPENAI_API_KEY: " OPENAI_API_KEY
echo ""

read -sp "Enter JOGET_APP_ID: " JOGET_APP_ID
echo ""

read -sp "Enter JOGET_TRAMITE_FORM_ID: " JOGET_TRAMITE_FORM_ID
echo ""

# Create temporary secret manifest
cat <<EOF > /tmp/ai-risk-analyzer-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ai-risk-analyzer-secrets
type: Opaque
stringData:
  JOGET_USERNAME: "$JOGET_USERNAME"
  JOGET_PASSWORD: "$JOGET_PASSWORD"
  OPENAI_API_KEY: "$OPENAI_API_KEY"
  JOGET_APP_ID: "$JOGET_APP_ID"
  JOGET_TRAMITE_FORM_ID: "$JOGET_TRAMITE_FORM_ID"  
EOF

# Seal the secret
echo ""
echo "Sealing secrets..."
kubeseal --scope cluster-wide --format yaml \
  < /tmp/ai-risk-analyzer-secrets.yaml \
  > ai-risk-analyzer-secrets.clusterwide.sealed.yaml

# Clean up
rm /tmp/ai-risk-analyzer-secrets.yaml

echo "✓ Sealed secret created: ai-risk-analyzer-secrets.clusterwide.sealed.yaml"
echo ""
echo "Next steps:"
echo "1. Review the sealed secret file"
echo "2. Commit to git: git add ai-risk-analyzer-secrets.clusterwide.sealed.yaml"
echo "3. Apply with: kubectl apply -f ai-risk-analyzer-secrets.clusterwide.sealed.yaml"
