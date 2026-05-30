# browser-use (MCP server)

Runs [browser-use](https://github.com/browser-use/browser-use) `0.12.9` as a
networked MCP server on Talos, using Ollama as the LLM backend.

## How it works

browser-use only ships a **stdio** MCP server (`browser-use --mcp`), which
cannot be reached over a Kubernetes `Service` on its own. The deployment wraps
that stdio process with [`mcp-proxy`](https://github.com/sparfenyuk/mcp-proxy),
which re-exposes it over **SSE**:

```
mcp-proxy --host 0.0.0.0 --port 8000 -- browser-use --mcp
```

`mcp-proxy` is installed at container start via `pip` (the base image is
Python based). MCP clients connect to the SSE endpoint:

```
http://browseruse.<namespace>.svc.cluster.local:8000/sse
```

## LLM backend (Ollama)

browser-use `0.12.9`'s MCP server has **no native Ollama provider**, it only
speaks OpenAI or Bedrock. Ollama is therefore used through its
OpenAI-compatible API:

- `OPENAI_BASE_URL=http://192.168.1.79:11434/v1` and a dummy `OPENAI_API_KEY`
  (ignored by Ollama) are set in the deployment, the OpenAI SDK reads these.
- The default model and provider come from `browseruse-config` (`config.json`,
  the browser-use "db-style" config), mounted via `BROWSER_USE_CONFIG_PATH`.
  Default model: **`qwen2.5:14b-instruct-q6_K`**. Change it in
  `browseruse-configmap.yaml`.

## Manifests

- `browseruse-pvc.yaml` provisions a `1Gi` volume mounted at
  `/root/.config/browseruse` so the browser profile and cookies survive
  restarts.
- `browseruse-configmap.yaml` holds the browser-use `config.json` that sets the
  default Ollama model.
- `browseruse-deployment.yaml` runs the wrapped MCP server headless against the
  Ollama OpenAI-compatible endpoint.
- `browseruse-service.yaml` exposes the SSE port `8000` as a `ClusterIP`.

## Configuration to verify

These two assumptions are best-effort for `0.12.9` and should be confirmed
against your image, the pod logs will tell you quickly if either is off:

- **config.json schema**: the db-style structure (`llm` map with
  `id`/`default`/`created_at`/`model`/`api_key`) is what browser-use generates.
  If the server ignores the default model and still tries `gpt-4.1-mini`,
  adjust the schema or pass the model per tool-call from the MCP client.
- **CLI availability**: this assumes the `browser-use` CLI is on `PATH` in the
  image with the `cli` extra. If it is not, change the command to
  `uvx --from 'browser-use[cli]' browser-use --mcp`.

## Note on the kustomization filename

Per the requested naming convention, the kustomize entrypoint is
`browseruse-kustomization.yaml`. Kustomize only auto-discovers a file named
exactly `kustomization.yaml`, so build it explicitly, e.g.:

```bash
kubectl kustomize --kustomization browseruse-kustomization.yaml .
```

If you drive these manifests through Argo CD with directory-based discovery,
rename the file to `kustomization.yaml` instead.
