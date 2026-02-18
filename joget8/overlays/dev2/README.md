# Fill these first
tls_crt="./tls.crt"

# --scope cluster-wide (usable in any namespace/name — less restrictive; use with care)
kubectl create secret generic wsagentes-tls-cert \
  --from-file=tls.crt="$tls_crt" \
  --dry-run=client -o json \
| kubeseal --format yaml --scope cluster-wide \
> wsagentes-tls-cert.clusterwide.sealed.yaml
```