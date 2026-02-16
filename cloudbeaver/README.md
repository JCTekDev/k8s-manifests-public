# CloudBeaver + Informix JDBC

This overlay keeps CloudBeaver stateless except for a single PVC that stores the workspace. The deployment now expects (optionally) a Kubernetes secret named `informix-jdbc` that contains the licensed Informix JDBC driver so the pod can load it without manual uploads.

## Supplying the Informix driver

1. Copy the licensed IBM Informix JDBC `.jar` into this repo at `drivers/informix-jdbc.jar` (rename your artifact if needed).
2. Run `kubectl apply -k .`. The kustomization bundles that file into a deterministic secret named `informix-jdbc`, so no manual secret creation is required.
3. Restart CloudBeaver if it is already running so the init container can copy the refreshed driver into the workspace.

> Need to source the driver from another location? Update `kustomization.yaml`'s `secretGenerator` entry to point at the alternate file or fall back to creating the `informix-jdbc` secret manually as before.

## What the manifests do

- `pvc.yaml` provisions a `256Mi` persistent workspace that keeps driver binaries, logs, and backups. Adjust the request if you need more space.
- The deployment mounts the `informix-jdbc` secret at `/opt/cloudbeaver/custom-drivers/informix` (read-only) so administrators can always retrieve the original artifact.
- An `initContainer` copies the driver into the workspace under `/opt/cloudbeaver/workspace/GlobalConfiguration/.dbeaver/drivers/informix/informix-jdbc.jar` before the main server starts. This is the location CloudBeaver scans when resolving driver libraries.
- If the secret is missing, the init container logs a warning and CloudBeaver still starts (you can later add the secret and restart the pod).

## Enabling the driver inside CloudBeaver

After the pod is running:

1. Sign in as an administrator.
2. Navigate to **Administration → Driver Management**.
3. Locate **IBM Informix** (or create a custom driver) and open the **Libraries** tab.
4. The uploaded `informix-jdbc.jar` should already be listed because it is present in the workspace. If it is not, click **Add File** and point CloudBeaver to `informix-jdbc.jar` in the workspace (`/opt/cloudbeaver/workspace/GlobalConfiguration/.dbeaver/drivers/informix`).
5. Save the driver and create a new connection using the Informix JDBC URL (for example, `jdbc:informix-sqli://<host>:<port>/<database>:INFORMIXSERVER=<server>`).

For details on managing drivers, see the CloudBeaver documentation: [Drivers management](https://dbeaver.com/docs/cloudbeaver/Drivers-Management/).
