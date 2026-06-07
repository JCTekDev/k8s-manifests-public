# browseruse-service

Kubernetes manifests for **browseruse-service**: a small FastAPI service that runs
[browser-use](https://github.com/browser-use/browser-use) agent tasks driven by a local
Ollama model (`ChatOllama`).

Source / image: `github.com/devopian/browseruse-service` →
`ghcr.io/devopian/browseruse-service:latest`.

## Why not the browser-use MCP server?

The browser-use **library** starts Chromium reliably in-cluster, but the bundled MCP
server (`browser-use --mcp`, 0.12.x) times out launching Chromium inside its own event
loop. This service uses the library directly and exposes a plain HTTP API.

## API

- `GET /health` - liveness + effective model/host
- `POST /run` - `{"task": "...", "max_steps": 25}` runs an agent task

## Config (env, set in the Deployment)

- `OLLAMA_HOST` - Ollama base host (no `/v1`), default `http://192.168.1.79:11434`
- `BROWSER_USE_MODEL` - Ollama model, default `qwen2.5:14b-instruct-q6_K`

## Notes

- A 1Gi memory-backed `/dev/shm` is mounted so Chromium can start.
- A `local-path` PVC is mounted at `/data` to persist the browser session.
- `BROWSER_USE_USER_DATA_DIR=/data/chrome-profile` provides a persistent Chrome
  profile directory with authenticated sessions (Google, Instagram, etc.).
- `BROWSER_USE_STORAGE_STATE` is intentionally not set. The service uses the full
  Chrome profile only, because storage state overrides profile session data.
- The Deployment uses `strategy: Recreate` because the PVC is `ReadWriteOnce`.

## Bootstrap: Manual Login

To seed the Chrome profile with authenticated sessions, use the bootstrap pod
(`bootstrap-login-pod.yaml`). This is NOT managed by ArgoCD and must be applied
manually:

1. Scale down the service (`replicas=0`) so the PVC is released.
2. `kubectl apply -f bootstrap-login-pod.yaml -n browseruse-service-infra`
3. `kubectl port-forward pod/browseruse-profile-login 6901:6901 -n browseruse-service-infra`
4. Open `https://localhost:6901`, launch Chrome with `--user-data-dir=/data/chrome-profile`,
   log in to the required accounts, then close Chrome.
5. Delete the pod and scale the service back up.

See the comments inside `bootstrap-login-pod.yaml` for full step-by-step commands.
