# dever-labs devcontainers

Shared, pre-built devcontainer images for the dever-labs organisation — ready for **human developers** and **AI coding agents** (GitHub Copilot, Claude Code).

All service repos reference an image from here. No per-repo builds, no drift between environments.

## Available images

| Image | Pull | Toolchain | Extras |
|-------|------|-----------|--------|
| [`dotnet-dev`](docs/dotnet-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/dotnet-dev:latest` | .NET 10 SDK | Docker-in-Docker, kubectl, Helm, minikube |
| [`frontend-dev`](docs/frontend-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/frontend-dev:latest` | Node.js LTS | Docker-in-Docker, kubectl, Helm, minikube |
| [`python-dev`](docs/python-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/python-dev:latest` | Python 3.13 | Docker-in-Docker, kubectl, Helm, minikube |
| [`go-dev`](docs/go-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/go-dev:latest` | Go (latest) | Docker-in-Docker, kubectl, Helm, minikube |
| [`infra-dev`](docs/infra-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/infra-dev:latest` | Terraform, Azure CLI | AWS CLI, GCP SDK, ArgoCD, Docker-in-Docker, kubectl, Helm, minikube |

All images include: **git**, **GitHub CLI**, **GitHub Copilot**, **Claude Code**, and **openclaw.ai**.

## Using an image in a service repo

Add a `.devcontainer/devcontainer.json` that references the pre-built image:

```jsonc
{
  "name": "my-service",
  "image": "ghcr.io/dever-labs/devcontainers/dotnet-dev:latest"
}
```

That's it. No build step in the service repo. When the shared image updates, every repo picks it up on the next container rebuild.

## Using with AI agents

These images are designed to work as autonomous agent environments, not just IDE containers.

### GitHub Copilot Coding Agent / Copilot Workspace

The images are compatible with [GitHub Copilot coding agent](https://docs.github.com/en/copilot/using-github-copilot/using-claude-sonnet-in-github-copilot). Reference the image in your repo's `.devcontainer/devcontainer.json` and Copilot will use it automatically.

### Claude Code

Claude Code is pre-installed as a VS Code extension (`anthropics.claude-code`). For headless agent use:

```bash
docker run --rm -it ghcr.io/dever-labs/devcontainers/dotnet-dev:latest bash
```

### Token forwarding

`GITHUB_TOKEN` is forwarded from the host environment into the container via `remoteEnv`. No re-authentication needed for `gh` CLI or git operations.

## How CI builds images

```
images/dotnet-dev/devcontainer.json
         │
         ▼  (push to main → GitHub Actions)
ghcr.io/dever-labs/devcontainers/dotnet-dev:latest   [public]
         │
         ▼  (service repos reference)
.devcontainer/devcontainer.json → "image": "ghcr.io/..."
```

Every push to `main` rebuilds all images with layer caching. A `workflow_dispatch` input lets you rebuild a single named image.

## One-time setup: make packages public

Changing package visibility on org-owned GHCR packages requires a classic PAT — `GITHUB_TOKEN` alone cannot do it.

1. Create a [classic PAT](https://github.com/settings/tokens/new) with the `write:packages` scope.
2. Add it as a repo secret named **`PACKAGES_PAT`**: **Settings → Secrets and variables → Actions → New repository secret**.

CI will then set each image to public automatically after every push. Existing private packages must be changed once manually: **GitHub → org → Packages → \<image\> → Package settings → Change visibility → Public**.

## Adding a new image

1. Create `images/<name>/devcontainer.json` using an existing image as a template.
2. Push to `main` — CI builds and pushes `ghcr.io/dever-labs/devcontainers/<name>:latest`.
3. Reference it in service repos.

## Modifying an existing image

Edit `images/<name>/devcontainer.json` and push to `main`. Service repos pick up the change on their next container rebuild — no changes needed in service repos.

## Conventions

- Base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
- Feature versions: pin to `major.minor` (e.g. `"version": "10.0"`) so patch updates flow automatically.
- Keep images generic for their persona — no project-specific tooling here.

