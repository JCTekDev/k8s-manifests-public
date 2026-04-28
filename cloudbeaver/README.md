# CloudBeaver

This overlay keeps CloudBeaver stateless except for a single PVC that stores the workspace.

## What the manifests do

- `pvc.yaml` provisions a `256Mi` persistent workspace that keeps driver binaries, logs, and backups. Adjust the request if you need more space.
- The deployment runs CloudBeaver with the workspace mounted at `/opt/cloudbeaver/workspace`.

For details on managing drivers, see the CloudBeaver documentation: [Drivers management](https://dbeaver.com/docs/cloudbeaver/Drivers-Management/).
