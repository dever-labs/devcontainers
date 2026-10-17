# GitHub Copilot instructions for dever-labs/devcontainers

This repo manages shared devcontainer base images for the dever-labs organisation.
Each image is defined as a `devcontainer.json` under `images/<name>/` and built by CI.

## Repository structure

- `images/<name>/devcontainer.json` — devcontainer feature definition for each image
- `images/Dockerfile` — shared base layer (Node, AI CLIs, k3d) used by every image except `flutter-dev`; AI CLI versions are pinned via ARGs
- `.github/workflows/pr-build.yml` — builds and smoke-tests affected images on PRs (`.github/scripts/smoke-test.sh`)
- `.github/workflows/build.yml` — builds changed images on push to main (and weekly), pushes to GHCR with `latest` and immutable `sha-<short>` tags
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
