# AI Risk Analyzer - Dev Overlay

Kubernetes manifests for deploying the AI Risk Analyzer to the development cluster.

## Prerequisites

- Kubernetes cluster with Sealed Secrets controller installed
- `kubectl` configured to access the cluster
- `kubeseal` CLI tool installed
- Access to GitHub Container Registry (ghcr.io)

## Configuration

### ConfigMap (ai-risk-analyzer-config.yaml)

Non-sensitive configuration:
- `JOGET_BASE_URL`: URL to Joget instance
- `JOGET_APP_ID`: Joget application ID
- `JOGET_TRAMITE_FORM_ID`: Joget form ID
- `LANGCHAIN_TRACING_V2`: Enable/disable LangChain tracing
- `LLM_TEMPERATURE`: Temperature setting for LLM

### Sealed Secrets (ai-risk-analyzer-secrets.clusterwide.sealed.yaml)

Sensitive credentials:
- `JOGET_USERNAME`: Joget admin username
- `JOGET_PASSWORD`: Joget admin password
- `OPENAI_API_KEY`: OpenAI API key

## Creating Sealed Secrets

Run the sealer script to create sealed secrets:

```bash
chmod +x ai-risk-analyzer-secrets-sealer.sh
./ai-risk-analyzer-secrets-sealer.sh
```

This will:
1. Prompt you for sensitive values
2. Create a SealedSecret manifest
3. Save it to `ai-risk-analyzer-secrets.clusterwide.sealed.yaml`

**Important**: Only commit the `.sealed.yaml` file, never the plain secret YAML.

## Deployment

### Using kubectl

```bash
# Apply the dev overlay
kubectl apply -k .

# Check deployment status
kubectl get pods -l app=ai-risk-analyzer
kubectl logs -f deployment/ai-risk-analyzer

# Check service
kubectl get svc ai-risk-analyzer
```

### Using kustomize

```bash
# Build and view manifests
kustomize build .

# Apply
kustomize build . | kubectl apply -f -
```

## Accessing the Service

The service is exposed as ClusterIP on port 80.

### Port Forward for Testing

```bash
kubectl port-forward svc/ai-risk-analyzer 8000:80
```

Then access:
- API: http://localhost:8000
- Health: http://localhost:8000/health
- Docs: http://localhost:8000/docs

### Example API Call

```bash
# Analyze a folio
curl -X POST "http://localhost:8000/analyze/34666095-2358-4109-a63d-abaf8c215e82"
```

## Updating the Image

The image tag is pinned in `kustomization.yaml`. To update:

1. Update the `newTag` field in `kustomization.yaml`
2. Commit and push
3. Apply the changes: `kubectl apply -k .`

## Troubleshooting

### Pod not starting

Check logs:
```bash
kubectl logs deployment/ai-risk-analyzer
kubectl describe pod -l app=ai-risk-analyzer
```

### Connection to Joget failing

Verify:
1. Joget service is running in the cluster
2. `JOGET_BASE_URL` in ConfigMap is correct
3. Network policies allow communication

### Secrets not found

Ensure SealedSecret is created and unsealed:
```bash
kubectl get sealedsecrets
kubectl get secrets ai-risk-analyzer-secrets
```

## Resource Limits

Current resource configuration:
- **Requests**: 100m CPU, 256Mi memory
- **Limits**: 500m CPU, 512Mi memory

Adjust in `base/deployment.yaml` if needed based on actual usage.

## Health Checks

- **Readiness Probe**: `/health` endpoint, checks every 30s after 10s delay
- **Liveness Probe**: `/health` endpoint, checks every 60s after 30s delay

## Scaling

To scale the deployment:

```bash
kubectl scale deployment/ai-risk-analyzer --replicas=3
```

Or update `replicas` in `base/deployment.yaml`.
