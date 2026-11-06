# dever-labs devcontainers

Shared, pre-built devcontainer images for the dever-labs organisation — ready
for human developers and AI coding agents (GitHub Copilot, Claude Code). Every
service repo references an image from here: no per-repo builds, no drift
between environments.

## Images

| Image                             | Toolchain                                                     |
| --------------------------------- | ------------------------------------------------------------- |
| [`dotnet-dev`](dotnet-dev.md)     | .NET 10 SDK                                                   |
| [`frontend-dev`](frontend-dev.md) | Node.js 26                                                    |
| [`python-dev`](python-dev.md)     | Python 3.14                                                   |
| [`go-dev`](go-dev.md)             | Go 1.26                                                       |
| [`flutter-dev`](flutter-dev.md)   | Flutter stable + Dart SDK                                     |
| [`infra-dev`](infra-dev.md)       | Terraform, Azure CLI, AWS CLI, gcloud, `hcloud`, ArgoCD, Flux |
| [`node-dev`](node-dev.md)         | Node.js 26                                                    |

Each is published as `ghcr.io/dever-labs/devcontainers/<image>:latest`. All
images include git, the GitHub CLI, the GitHub Copilot CLI, Claude Code, the
`agent-personas` review agents and [devx](https://github.com/dever-labs/devx);
all but `flutter-dev` add Docker-outside-of-Docker, kubectl, Helm and k3d.

## Using an image

Reference the image from your repo's `.devcontainer/devcontainer.json`:

```jsonc
{
  "name": "my-service",
  "image": "ghcr.io/dever-labs/devcontainers/<image>:latest",
}
```

The [README](https://github.com/dever-labs/devcontainers#readme) has the full
template (features, mounts, Ollama host setup), the optional features and how
CI builds and tags the images. Authentication inside the containers is
covered in [GitHub authentication](github-auth.md).
