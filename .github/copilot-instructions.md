# GitHub Copilot instructions for dever-labs/devcontainers

This repo manages shared devcontainer base images for the dever-labs organisation.
Each image is defined as a `devcontainer.json` under `images/<name>/` and built by CI.

## Repository structure

- `images/<name>/.devcontainer/devcontainer.json` — devcontainer feature definition for each image
- `.github/workflows/build.yml` — builds changed images on push to main, pushes to GHCR

## Conventions

- Base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
- Feature versions: pin to major.minor (e.g. `"version": "10.0"`) so patch updates flow automatically
- Never add repo-specific tooling here — keep images generic for their persona (dotnet-service, frontend, etc.)
- All images are pushed to `ghcr.io/dever-labs/devcontainers/<name>:latest` (e.g. `dotnet-dev`, `frontend-dev`)

## When adding or modifying features

- Prefer official devcontainer features from `ghcr.io/devcontainers/features/`
- Test locally with `devcontainer build --workspace-folder images/<name>` before pushing
- After CI pushes the image, verify by pulling: `docker pull ghcr.io/dever-labs/devcontainers/<name>:latest`
