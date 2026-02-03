# Put the Azure DevOps Agent container image in the ACR (Azure Container Registry)

## Create the image
Run the following command within that directory:
```
docker build --tag "azp-agent:linux" --file "./azp-agent-linux.dockerfile" .
```
## Login
```
echo <GITHUB_TOKEN> | docker login ghcr.io -u <GITHUB_USERNAME> --password-stdin
```
## Prepare the image for GHCR push
```
docker tag azp-agent:linux ghcr.io/<GITHUB_USERNAME>/azp-agent:linux
```

## Push the image to GHCR
```
docker push ghcr.io/<GITHUB_USERNAME>/azp-agent:linux
```