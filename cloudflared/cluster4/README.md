FILE_PATH="/home/administrator/.cloudflared/cert.pem"

kubectl create secret generic cloudflared-cert \
  --from-file=cert.pem="$FILE_PATH" \
  --dry-run=client -o json \
| kubeseal --format yaml --scope cluster-wide \
> cloudflared-cert.clusterwide.sealed.yaml


FILE_PATH="/home/administrator/.cloudflared/4e834393-917f-4463-8972-f858a61c5ec9.json"

kubectl create secret generic cloudflared-credentials \
  --from-file=credentials.json="$FILE_PATH" \
  --dry-run=client -o json \
| kubeseal --format yaml --scope cluster-wide \
> cloudflared-credentials.clusterwide.sealed.yaml