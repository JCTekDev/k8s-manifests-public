# Joget DX 9 Kubernetes Manifests

Kustomize manifests for running Joget DX 9 on Kubernetes.

## Structure

- `base/`: reusable core manifests (MySQL + Joget + RBAC)
- `overlays/dev/`: development overlay with ingress

## Quick Start

```sh
kubectl apply -k overlays/dev
```

Then open:

- http://joget9.lan/jw

## Database Setup in Joget

Use these values on first launch:

- Database Type: MySQL
- Host: `mysql`
- Port: `3306`
- Database Name: `jwdb`
- Username: `joget`
- Password: `joget`

## Versions

- Joget Image: `quay.io/joget/joget-dx9-tomcat11:9.0-SNAPSHOT`
- MySQL Image: `mysql:8.4`

MySQL 8.4 is used as an LTS choice under Joget DX 9's documented support for MySQL 8 and above.
