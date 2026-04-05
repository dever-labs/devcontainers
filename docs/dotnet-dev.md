# dotnet-dev

Pre-built devcontainer for .NET services — APIs, workers, gRPC services, and background jobs. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| .NET SDK | 10.0 (patch auto-updates) | Build, test, publish |
| Docker-in-Docker | latest | Build images, run containers inside the devcontainer |
| kubectl | latest | Deploy to and inspect Kubernetes clusters |
| Helm | latest | Install and manage Helm charts |
| minikube | latest | Local Kubernetes cluster (auto-started on container start) |
| git | latest | Source control |
| GitHub CLI (`gh`) | latest | PRs, issues, releases, Actions |
| openclaw.ai | latest | AI agent tooling (installed on create) |

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `ms-dotnettools.csdevkit` | C# Dev Kit (solution explorer, test runner) |
| `ms-dotnettools.csharp` | C# language server, IntelliSense, debugging |

## Use cases

### ASP.NET Core Web API

```jsonc
// .devcontainer/devcontainer.json in your service repo
{
  "name": "my-api",
  "image": "ghcr.io/dever-labs/devcontainers/dotnet-dev:latest",
  "forwardPorts": [8080, 8443],
  "portsAttributes": {
    "8080": { "label": "HTTP" },
    "8443": { "label": "HTTPS" }
  }
}
```

### Worker service with local Kubernetes

minikube starts automatically when the container starts. You can deploy Helm charts directly against the local cluster:

```bash
helm upgrade --install my-worker ./charts/my-worker --namespace dev --create-namespace
kubectl logs -n dev deploy/my-worker -f
```

### Running tests

```bash
dotnet test --logger "console;verbosity=detailed"
```

### AI agent use (Copilot coding agent / Claude Code)

No extra configuration needed. The image is wired for agent use out of the box:
- `GITHUB_TOKEN` is forwarded from the host so `gh` and git operations authenticate without prompts.
- minikube is ready for agents that need to validate Kubernetes deployments.
- Claude Code and Copilot extensions are pre-installed for VS Code / Codespaces agent runs.

## Updating the .NET version

Edit `images/dotnet-dev/devcontainer.json` and change the `version` field:

```jsonc
"ghcr.io/devcontainers/features/dotnet:2": {
  "version": "11.0"   // bump major.minor; patches flow automatically
}
```

Push to `main` — CI rebuilds and pushes the new image. All service repos pick it up on next container rebuild.
