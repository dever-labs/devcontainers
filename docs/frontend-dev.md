# frontend-dev

Pre-built devcontainer for frontend applications — React, Vue, Angular, Next.js, Remix, and any Node-based project. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 26 | Runtime and package management |
| npm / pnpm / yarn | via corepack | Package managers (`corepack enable pnpm` to activate pnpm) |
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
| `esbenp.prettier-vscode` | Code formatting |
| `dbaeumer.vscode-eslint` | Linting |
| `bradlc.vscode-tailwindcss` | Tailwind CSS IntelliSense |
| `ms-vscode.vscode-typescript-next` | Latest TypeScript language features |

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

With a k3d cluster running (`"postStartCommand": "k3d-cluster-init"` in your repo's `devcontainer.json`), build an image and deploy:

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

Node.js comes from the shared `images/Dockerfile` (also used by `node-dev`, `dotnet-dev`, `go-dev`, `python-dev` and `infra-dev`). In a pull request, change the `NODE_MAJOR` ARG at the top of that file (e.g. `ARG NODE_MAJOR=28`).
