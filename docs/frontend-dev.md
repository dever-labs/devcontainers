# frontend-dev

Pre-built devcontainer for frontend applications — React, Vue, Angular, Next.js, Remix, and any Node-based project. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | LTS | Runtime and package management |
| npm / pnpm / yarn | via corepack | Package managers (`corepack enable pnpm` to activate pnpm) |
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
| `esbenp.prettier-vscode` | Code formatting |
| `dbaeumer.vscode-eslint` | Linting |
| `bradlc.vscode-tailwindcss` | Tailwind CSS IntelliSense |

## Use cases

### React / Next.js app

```jsonc
// .devcontainer/devcontainer.json in your service repo
{
  "name": "my-frontend",
  "image": "ghcr.io/dever-labs/devcontainers/frontend-dev:latest",
  "forwardPorts": [3000],
  "portsAttributes": {
    "3000": { "label": "Dev server", "onAutoForward": "openBrowser" }
  },
  "postAttachCommand": "npm install"
}
```

### Enabling pnpm

corepack is bundled with Node.js. Enable pnpm once inside the container:

```bash
corepack enable pnpm
pnpm install
```

Or add it to your service repo's `postCreateCommand`:

```jsonc
{
  "postCreateCommand": "corepack enable pnpm && pnpm install"
}
```

### Running a Storybook alongside the app

```jsonc
{
  "forwardPorts": [3000, 6006],
  "portsAttributes": {
    "3000": { "label": "App" },
    "6006": { "label": "Storybook" }
  }
}
```

### Deploying a frontend to local Kubernetes

minikube starts automatically. Build an image with Docker-in-Docker and deploy:

```bash
docker build -t my-frontend:local .
helm upgrade --install my-frontend ./charts/my-frontend \
  --set image.repository=my-frontend \
  --set image.tag=local
```

### AI agent use (Copilot coding agent / Claude Code)

- `GITHUB_TOKEN` is forwarded so `gh` and git work without prompts.
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `npm test`, `npm run build`, and validate output without leaving the container.

## Updating Node.js

Edit `images/frontend-dev/devcontainer.json`:

```jsonc
"ghcr.io/devcontainers/features/node:1": {
  "version": "22"   // pin to a specific major, or keep "lts"
}
```

Push to `main` — all service repos pick it up on next rebuild.
