# infra-dev

Pre-built devcontainer for infrastructure and platform engineering — Terraform, multi-cloud CLIs, Kubernetes cluster management, and GitOps. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | latest | Infrastructure as Code |
| Azure CLI | latest | Azure resource management |
| AWS CLI v2 | latest | AWS resource management |
| Google Cloud SDK (`gcloud`) | latest | GCP resource management |
| ArgoCD CLI | latest | GitOps deployments |
| Docker-in-Docker | latest | Build images, run containers inside the devcontainer |
| kubectl | latest | Kubernetes cluster management |
| Helm | latest | Helm chart installation and management |
| minikube | latest | Local Kubernetes cluster (auto-started on container start) |
| git | latest | Source control |
| GitHub CLI (`gh`) | latest | PRs, issues, releases, Actions |
| openclaw.ai | latest | AI agent tooling (installed on create) |

> AWS CLI, GCP SDK, and ArgoCD CLI are installed via shell on container create because the devcontainers-contrib features have known CI reliability issues.

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `hashicorp.terraform` | Terraform syntax, validation, formatting |
| `ms-kubernetes-tools.vscode-kubernetes-tools` | Kubernetes resource explorer and kubectl integration |
| `ms-azuretools.vscode-azureterraform` | Azure-specific Terraform tooling |

## Use cases

### Terraform module development (Azure)

```jsonc
// .devcontainer/devcontainer.json in your infra repo
{
  "name": "my-infra",
  "image": "ghcr.io/dever-labs/devcontainers/infra-dev:latest",
  "remoteEnv": {
    "ARM_CLIENT_ID": "${localEnv:ARM_CLIENT_ID}",
    "ARM_CLIENT_SECRET": "${localEnv:ARM_CLIENT_SECRET}",
    "ARM_TENANT_ID": "${localEnv:ARM_TENANT_ID}",
    "ARM_SUBSCRIPTION_ID": "${localEnv:ARM_SUBSCRIPTION_ID}"
  }
}
```

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Multi-cloud credentials

Forward credentials from your host environment via `remoteEnv`. Example for all three clouds:

```jsonc
{
  "remoteEnv": {
    // Azure
    "ARM_CLIENT_ID": "${localEnv:ARM_CLIENT_ID}",
    "ARM_CLIENT_SECRET": "${localEnv:ARM_CLIENT_SECRET}",
    "ARM_TENANT_ID": "${localEnv:ARM_TENANT_ID}",
    "ARM_SUBSCRIPTION_ID": "${localEnv:ARM_SUBSCRIPTION_ID}",
    // AWS
    "AWS_ACCESS_KEY_ID": "${localEnv:AWS_ACCESS_KEY_ID}",
    "AWS_SECRET_ACCESS_KEY": "${localEnv:AWS_SECRET_ACCESS_KEY}",
    "AWS_DEFAULT_REGION": "${localEnv:AWS_DEFAULT_REGION}",
    // GCP
    "GOOGLE_APPLICATION_CREDENTIALS": "${localEnv:GOOGLE_APPLICATION_CREDENTIALS}"
  }
}
```

### GitOps with ArgoCD

```bash
# Log in to an ArgoCD instance
argocd login <argocd-server> --username admin --password <password>

# Sync an application
argocd app sync my-app

# Check rollout status
argocd app wait my-app --health
```

### Local Kubernetes with Helm

minikube starts automatically. Install and iterate on charts locally before promoting to a real cluster:

```bash
helm upgrade --install my-stack ./charts/my-stack \
  --namespace dev \
  --create-namespace \
  --values ./charts/my-stack/values.dev.yaml
kubectl get all -n dev
```

### Testing Terraform with Terratest

```bash
cd test
go test -v -timeout 30m ./...
```

### AI agent use (Copilot coding agent / Claude Code)

- `GITHUB_TOKEN` is forwarded so `gh` and git work without prompts.
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `terraform plan`, validate Kubernetes manifests with `kubectl apply --dry-run=client`, and iterate on Helm charts against minikube without leaving the container.
- Forward cloud credentials via `remoteEnv` in service-repo devcontainer for fully autonomous provisioning agents.

## Notes

- **First cloud login after container create**: interactive `az login`, `aws configure`, or `gcloud auth login` is required unless credentials are forwarded via `remoteEnv`.
- **minikube** auto-starts with the `docker` driver. If Docker-in-Docker is slow to initialise, the start may take 30–60 seconds on first run.
