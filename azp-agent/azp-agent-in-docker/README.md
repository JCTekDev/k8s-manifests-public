# Put the Azure Pipelines Agent container image in the ACR (Azure Container Registry)

## Create the image
Run the following command within that directory:
```
docker build --tag "azp-agent-alpine:latest" --file "./azp-agent-alpine.dockerfile" .
```
## Login
```
echo <GITHUB_TOKEN> | docker login ghcr.io -u <GITHUB_USERNAME> --password-stdin
```
## Prepare the image for GHCR push
```
docker tag azp-agent-alpine:latest ghcr.io/<GITHUB_USERNAME>/azp-agent-alpine:latest
```

## Push the image to GHCR
```
docker push ghcr.io/<GITHUB_USERNAME>/azp-agent-alpine:latest
```

Official Azure Pipelines Agent Container Documentation at: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops