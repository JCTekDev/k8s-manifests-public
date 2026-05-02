# Joget DX 9 Dev Overlay

This overlay deploys Joget DX 9 and MySQL with dev-friendly ingress settings.

## Apply

```sh
kubectl apply -k overlays/dev
```

## Access

- URL: http://joget9.lan/jw
- Database Host: mysql.<namespace>.svc.cluster.local
- Database Port: 3306
- Database Name: jwdb
- Database User: joget
- Database Password: joget

## Notes

- MySQL image is pinned to `mysql:8.4` (LTS baseline, aligned with Joget DX 9 MySQL 8+ support).
- Change default credentials in `base/10-mysql-secret.yaml` before non-dev usage.
