# infra-dev

Pre-built devcontainer for infrastructure and platform engineering — Terraform, multi-cloud CLIs, Kubernetes cluster management, and GitOps. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | 1.15 (patch auto-updates) | Infrastructure as Code |
| Azure CLI | 2.86 (patch auto-updates) | Azure resource management |
| AWS CLI v2 | latest | AWS resource management |
| Google Cloud CLI (`gcloud`) | apt (latest) | GCP resource management |
| Hetzner Cloud CLI (`hcloud`) | 1.70.1 | Hetzner resource management |
| ArgoCD CLI | 3.5.5 | GitOps deployments |
| Flux CLI | 2.9.6 | Flux GitOps bootstrap and reconciliation |
| Docker-outside-of-Docker | latest | Build images and run containers via the host Docker socket |
| kubectl | 1.36 | Kubernetes cluster management |
| Helm | 4.1 (patch auto-updates) | Helm chart installation and management |
| k3d | 5.8.3 (pinned in `images/Dockerfile`) | Local Kubernetes cluster — start it with `k3d-cluster-init` |
| git | latest | Source control |
| GitHub CLI (`gh`) | 2.92 (patch auto-updates) | PRs, issues, releases, Actions |

> ArgoCD, Flux and `hcloud` are installed in the `infra` stage of `images/Dockerfile` with checksum verification; bump the `ARGOCD_VERSION`, `FLUX_VERSION` and `HCLOUD_VERSION` ARGs deliberately.

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
    "GOOGLE_APPLICATION_CREDENTIALS": "${localEnv:GOOGLE_APPLICATION_CREDENTIALS}",
    // Hetzner
    "HCLOUD_TOKEN": "${localEnv:HCLOUD_TOKEN}"
  }
}
```

### GitOps with ArgoCD / Flux

```bash
argocd login <argocd-server> --username admin --password <password>
argocd app sync my-app

flux check --pre
flux get kustomizations
```

### Local Kubernetes with Helm

With a k3d cluster running (`"postStartCommand": "k3d-cluster-init"` in your repo's `devcontainer.json`), install and iterate on charts locally before promoting to a real cluster:

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
- Agents can run `terraform plan`, validate Kubernetes manifests with `kubectl apply --dry-run=client`, and iterate on Helm charts against the local k3d cluster without leaving the container.
- Forward cloud credentials via `remoteEnv` in service-repo devcontainer for fully autonomous provisioning agents.

## Notes

- **First cloud login after container create**: interactive `az login`, `aws configure`, `gcloud auth login`, or `hcloud context create` is required unless credentials are forwarded via `remoteEnv`.
- **k3d** starts when you run `k3d-cluster-init` (e.g. via `postStartCommand`) and is ready in ~15–45 seconds. The cluster joins the devcontainer's Docker network so `kubectl` and `helm` work immediately without port-forwarding tricks.
