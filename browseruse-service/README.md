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
- A `local-path` PVC is mounted at `/data` to persist the browser session. The app
  stores cookies/localStorage in `/data/storage_state.json` (env
  `BROWSER_USE_STORAGE_STATE`); browser-use loads it on connect and writes it back
  automatically. A persistent `user_data_dir` is intentionally not used (browser-use
  0.12.x copies it to a temp dir and never writes it back).
- The Deployment uses `strategy: Recreate` because the PVC is `ReadWriteOnce`.
