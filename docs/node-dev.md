# node-dev

Pre-built devcontainer for general Node.js / TypeScript projects (services, CLIs, libraries). For browser apps with Tailwind and similar, see [`frontend-dev`](frontend-dev.md). Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 26 | Runtime and package management |
| npm / pnpm / yarn | via corepack | Package managers (`corepack enable pnpm` to activate pnpm) |
| Docker-outside-of-Docker | latest | Build images and run containers via the host Docker socket |
| kubectl | 1.36 | Deploy to and inspect Kubernetes clusters |
| Helm | 4.1 | Install and manage Helm charts |
| k3d | 5.8.3 | Local Kubernetes cluster (`k3d-cluster-init`) |
| git | latest | Source control |
| GitHub CLI (`gh`) | 2.92 | PRs, issues, releases, Actions |
| Copilot CLI, Claude Code | pinned in `images/Dockerfile` | AI agents |

## VS Code extensions

`github.copilot`, `github.copilot-chat`, `anthropics.claude-code`, `esbenp.prettier-vscode`, `dbaeumer.vscode-eslint`, `ms-vscode.vscode-typescript-next`.

## Usage

```jsonc
// .devcontainer/devcontainer.json in your service repo
{
  "name": "my-node-service",
  "image": "ghcr.io/dever-labs/devcontainers/node-dev:latest",
  "postCreateCommand": "npm install"
}
```

Pin to an immutable build with `node-dev:<yyyymmdd>-<sha>` instead of `latest` when you need reproducibility.
