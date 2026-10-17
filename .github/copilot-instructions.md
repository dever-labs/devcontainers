# GitHub Copilot instructions for dever-labs/devcontainers

This repo manages shared devcontainer base images for the dever-labs organisation.
Each image is defined as a `devcontainer.json` under `images/<name>/` and built by CI.

## Repository structure

- `images/<name>/.devcontainer/devcontainer.json` — devcontainer feature definition for each image
- `.github/workflows/build.yml` — builds changed images on push to main, pushes to GHCR
- `features/src/agent-personas/` — shared read-only review agent personas (architect, devops, docs, security, qa, po, pm) for GitHub Copilot Chat/CLI. Every base image includes this feature so all dever-labs devcontainers review changes with the same personas.

## Conventions

- Base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
- Feature versions: pin to major.minor (e.g. `"version": "10.0"`) so patch updates flow automatically
- Never add repo-specific tooling here — keep images generic for their persona (dotnet-service, frontend, etc.)
- All images are pushed to `ghcr.io/dever-labs/devcontainers/<name>:latest` (e.g. `dotnet-dev`, `frontend-dev`)

## When adding or modifying features

- Prefer official devcontainer features from `ghcr.io/devcontainers/features/`
- Test locally with `devcontainer build --workspace-folder images/<name>` before pushing
- After CI pushes the image, verify by pulling: `docker pull ghcr.io/dever-labs/devcontainers/<name>:latest`
- To add or change a review persona, edit `features/src/agent-personas/agents/<name>.agent.md` and bump the feature version in `features/src/agent-personas/devcontainer-feature.json` — all images pick it up on their next rebuild
