# dotnet-dev

Pre-built devcontainer for .NET services — APIs, workers, gRPC services, and background jobs. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| .NET SDK | 10.0 (patch auto-updates) | Build, test, publish |
| Docker-outside-of-Docker | latest | Build images and run containers via the host Docker socket |
| kubectl | 1.36 | Deploy to and inspect Kubernetes clusters |
| Helm | 4.1 (patch auto-updates) | Install and manage Helm charts |
| k3d | 5.8.3 (pinned in `images/Dockerfile`) | Local Kubernetes cluster — start it with `k3d-cluster-init` |
| git | latest | Source control |
| GitHub CLI (`gh`) | 2.92 (patch auto-updates) | PRs, issues, releases, Actions |

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `ms-dotnettools.csdevkit` | C# Dev Kit (solution explorer, test runner) |
| `ms-dotnettools.csharp` | C# language server, IntelliSense, debugging |
| `ms-dotnettools.vscode-dotnet-runtime` | .NET runtime acquisition for extensions |
| `humao.rest-client` | Send `.http` requests to test APIs |
| `editorconfig.editorconfig` | Honour `.editorconfig` settings |

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

Once a k3d cluster is running (add `"postStartCommand": "k3d-cluster-init"` to your repo's `devcontainer.json`), you can deploy Helm charts directly against the local cluster:

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
- GitHub auth comes from the shared `dever-labs-gh-config` volume: run `gh auth login` once ([docs/github-auth.md](github-auth.md)).
- A k3d cluster is ready for agents that need to validate Kubernetes deployments.
- Claude Code and Copilot extensions are pre-installed for VS Code / Codespaces agent runs.

## Updating the .NET version

Edit `images/dotnet-dev/devcontainer.json` and change the `version` field:

```jsonc
"ghcr.io/devcontainers/features/dotnet:2": {
  "version": "11.0"   // bump major.minor; patches flow automatically
}
```

Push to `main` — CI rebuilds and pushes the new image. All service repos pick it up on next container rebuild.
